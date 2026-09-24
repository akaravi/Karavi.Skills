using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Runtime.InteropServices;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading;

namespace KaraviTerminal
{
    public sealed class PtySession : IDisposable
    {
        const int ProcThreadAttributePseudoConsole = 0x00020016;
        const uint ExtendedStartupInfoPresent = 0x00080000;
        const uint CreateUnicodeEnvironment = 0x00000400;
        const uint StillActive = 259;
        const uint WaitTimeout = 0x00000102;

        readonly object gate = new object();
        readonly StringBuilder raw = new StringBuilder();
        readonly List<string> buffer = new List<string>();
        readonly Decoder decoder = Encoding.UTF8.GetDecoder();
        readonly int maxRawChars;
        IntPtr pseudoConsole = IntPtr.Zero;
        IntPtr inputWrite = IntPtr.Zero;
        IntPtr outputRead = IntPtr.Zero;
        IntPtr processHandle = IntPtr.Zero;
        Thread reader;
        bool disposed;
        bool exited;
        bool lastLineComplete = true;
        int exitCode = -1;

        PtySession(int maxRawChars)
        {
            this.maxRawChars = maxRawChars;
        }

        public string Id { get; set; }
        public string Command { get; set; }
        public string WorkingDirectory { get; set; }
        public int ProcessId { get; private set; }
        public int Columns { get; private set; }
        public int Rows { get; private set; }

        public int RawLength
        {
            get { lock (gate) { return raw.Length; } }
        }

        public static PtySession Start(string applicationName, string commandLine, string workingDirectory, int columns, int rows, string environmentBlock, int maxRawChars)
        {
            if (string.IsNullOrEmpty(applicationName)) throw new ArgumentException("Application name is required.");
            if (columns < 1 || rows < 1) throw new ArgumentOutOfRangeException("columns");

            IntPtr inputRead, inputWrite, outputRead, outputWrite;
            if (!CreatePipe(out inputRead, out inputWrite, IntPtr.Zero, 65536))
                throw new Win32Exception(Marshal.GetLastWin32Error(), "CreatePipe(input) failed.");
            if (!CreatePipe(out outputRead, out outputWrite, IntPtr.Zero, 65536))
                throw new Win32Exception(Marshal.GetLastWin32Error(), "CreatePipe(output) failed.");

            IntPtr hpc;
            int hr = CreatePseudoConsole(new Coord { X = (short)columns, Y = (short)rows }, inputRead, outputWrite, 0, out hpc);
            CloseHandle(inputRead);
            CloseHandle(outputWrite);
            if (hr != 0)
            {
                CloseHandle(inputWrite);
                CloseHandle(outputRead);
                throw new InvalidOperationException("CreatePseudoConsole failed: 0x" + hr.ToString("X8"));
            }

            IntPtr attributeList = IntPtr.Zero;
            IntPtr environment = IntPtr.Zero;
            PROCESS_INFORMATION processInfo = new PROCESS_INFORMATION();
            try
            {
                IntPtr size = IntPtr.Zero;
                InitializeProcThreadAttributeList(IntPtr.Zero, 1, 0, ref size);
                attributeList = Marshal.AllocHGlobal(size);
                if (!InitializeProcThreadAttributeList(attributeList, 1, 0, ref size))
                    throw new Win32Exception(Marshal.GetLastWin32Error(), "InitializeProcThreadAttributeList failed.");
                if (!UpdateProcThreadAttribute(attributeList, 0, (IntPtr)ProcThreadAttributePseudoConsole, hpc, (IntPtr)IntPtr.Size, IntPtr.Zero, IntPtr.Zero))
                    throw new Win32Exception(Marshal.GetLastWin32Error(), "UpdateProcThreadAttribute failed.");

                STARTUPINFOEX startup = new STARTUPINFOEX();
                startup.StartupInfo.cb = Marshal.SizeOf(typeof(STARTUPINFOEX));
                startup.lpAttributeList = attributeList;

                if (!string.IsNullOrEmpty(environmentBlock))
                    environment = Marshal.StringToHGlobalUni(environmentBlock);

                if (!CreateProcess(applicationName, commandLine, IntPtr.Zero, IntPtr.Zero, false, ExtendedStartupInfoPresent | CreateUnicodeEnvironment, environment, workingDirectory, ref startup, out processInfo))
                    throw new Win32Exception(Marshal.GetLastWin32Error(), "CreateProcess failed.");
            }
            catch
            {
                ClosePseudoConsole(hpc);
                CloseHandle(inputWrite);
                CloseHandle(outputRead);
                throw;
            }
            finally
            {
                if (attributeList != IntPtr.Zero)
                {
                    DeleteProcThreadAttributeList(attributeList);
                    Marshal.FreeHGlobal(attributeList);
                }
                if (environment != IntPtr.Zero) Marshal.FreeHGlobal(environment);
                if (processInfo.hThread != IntPtr.Zero) CloseHandle(processInfo.hThread);
            }

            PtySession session = new PtySession(maxRawChars);
            session.pseudoConsole = hpc;
            session.inputWrite = inputWrite;
            session.outputRead = outputRead;
            session.processHandle = processInfo.hProcess;
            session.ProcessId = processInfo.dwProcessId;
            session.Columns = columns;
            session.Rows = rows;
            session.reader = new Thread(session.ReadLoop);
            session.reader.IsBackground = true;
            session.reader.Start();
            return session;
        }

        public void Write(string text)
        {
            if (disposed || exited) throw new InvalidOperationException("PTY session is not alive.");
            byte[] bytes = Encoding.UTF8.GetBytes(text ?? string.Empty);
            uint written;
            if (!WriteFile(inputWrite, bytes, (uint)bytes.Length, out written, IntPtr.Zero))
                throw new Win32Exception(Marshal.GetLastWin32Error(), "WriteFile failed.");
        }

        public void Resize(int columns, int rows)
        {
            if (disposed) throw new ObjectDisposedException("PtySession");
            int hr = ResizePseudoConsole(pseudoConsole, new Coord { X = (short)columns, Y = (short)rows });
            if (hr != 0) throw new InvalidOperationException("ResizePseudoConsole failed: 0x" + hr.ToString("X8"));
            lock (gate)
            {
                Columns = columns;
                Rows = rows;
            }
        }

        public bool IsAlive
        {
            get
            {
                if (disposed || processHandle == IntPtr.Zero) return false;
                return WaitForSingleObject(processHandle, 0) == WaitTimeout;
            }
        }

        public int ExitCode
        {
            get
            {
                if (processHandle == IntPtr.Zero) return exitCode;
                uint code;
                if (!GetExitCodeProcess(processHandle, out code)) return exitCode;
                if (code == StillActive) return -1;
                exitCode = unchecked((int)code);
                exited = true;
                return exitCode;
            }
        }

        public string GetBuffer(bool stripAnsi)
        {
            lock (gate)
            {
                int start = buffer.Count > Rows ? buffer.Count - Rows : 0;
                string[] slice = new string[buffer.Count - start];
                for (int i = 0; i < slice.Length; i++) slice[i] = buffer[start + i];
                string content = string.Join("\n", slice);
                return stripAnsi ? StripAnsi(content) : content;
            }
        }

        public void Dispose()
        {
            if (disposed) return;
            disposed = true;
            IntPtr hpc = pseudoConsole;
            pseudoConsole = IntPtr.Zero;
            if (hpc != IntPtr.Zero)
            {
                Thread closer = new Thread(delegate()
                {
                    try { ClosePseudoConsole(hpc); } catch (Exception) { }
                });
                closer.IsBackground = true;
                closer.Start();
                if (!closer.Join(1500))
                {
                    try { if (processHandle != IntPtr.Zero) TerminateProcess(processHandle, 1); } catch (Exception) { }
                    closer.Join(500);
                }
            }
            try { if (processHandle != IntPtr.Zero && IsAlive) TerminateProcess(processHandle, 1); } catch (Exception) { }
            if (inputWrite != IntPtr.Zero) { CloseHandle(inputWrite); inputWrite = IntPtr.Zero; }
            if (outputRead != IntPtr.Zero) { CloseHandle(outputRead); outputRead = IntPtr.Zero; }
            if (processHandle != IntPtr.Zero) { CloseHandle(processHandle); processHandle = IntPtr.Zero; }
            lock (gate)
            {
                raw.Length = 0;
                buffer.Clear();
            }
        }

        void ReadLoop()
        {
            byte[] bytes = new byte[4096];
            char[] chars = new char[8192];
            while (!disposed)
            {
                uint read;
                bool ok = ReadFile(outputRead, bytes, (uint)bytes.Length, out read, IntPtr.Zero);
                if (!ok || read == 0)
                {
                    exited = true;
                    break;
                }
                int count = decoder.GetChars(bytes, 0, (int)read, chars, 0);
                if (count > 0) Append(new string(chars, 0, count));
            }
        }

        void Append(string data)
        {
            lock (gate)
            {
                raw.Append(data);
                if (raw.Length > maxRawChars)
                    raw.Remove(0, raw.Length - (maxRawChars / 2));
                string[] lines = Regex.Split(data, "\r?\n");
                for (int i = 0; i < lines.Length; i++)
                {
                    string line = lines[i];
                    if (i == 0 && buffer.Count > 0 && !lastLineComplete)
                        buffer[buffer.Count - 1] = buffer[buffer.Count - 1] + line;
                    else if (line.Length > 0 || i < lines.Length - 1)
                        buffer.Add(line);
                }
                lastLineComplete = data.EndsWith("\n") || data.EndsWith("\r\n");
                int maxLines = Rows * 2;
                if (buffer.Count > maxLines) buffer.RemoveRange(0, buffer.Count - maxLines);
            }
        }

        static string StripAnsi(string text)
        {
            if (string.IsNullOrEmpty(text)) return string.Empty;
            text = Regex.Replace(text, "\u001b\\[[0-?]*[ -/]*[@-~]", string.Empty);
            text = Regex.Replace(text, "\u001b\\][^\u0007\u001b]*(?:\u0007|\u001b\\\\)", string.Empty);
            return text.Replace("\r", string.Empty);
        }

        [StructLayout(LayoutKind.Sequential)]
        struct Coord
        {
            public short X;
            public short Y;
        }

        [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
        struct STARTUPINFO
        {
            public int cb;
            public string lpReserved;
            public string lpDesktop;
            public string lpTitle;
            public int dwX;
            public int dwY;
            public int dwXSize;
            public int dwYSize;
            public int dwXCountChars;
            public int dwYCountChars;
            public int dwFillAttribute;
            public int dwFlags;
            public short wShowWindow;
            public short cbReserved2;
            public IntPtr lpReserved2;
            public IntPtr hStdInput;
            public IntPtr hStdOutput;
            public IntPtr hStdError;
        }

        [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
        struct STARTUPINFOEX
        {
            public STARTUPINFO StartupInfo;
            public IntPtr lpAttributeList;
        }

        [StructLayout(LayoutKind.Sequential)]
        struct PROCESS_INFORMATION
        {
            public IntPtr hProcess;
            public IntPtr hThread;
            public int dwProcessId;
            public int dwThreadId;
        }

        [DllImport("kernel32.dll", SetLastError = true)]
        static extern int CreatePseudoConsole(Coord size, IntPtr hInput, IntPtr hOutput, uint dwFlags, out IntPtr phpc);

        [DllImport("kernel32.dll", SetLastError = true)]
        static extern int ResizePseudoConsole(IntPtr hpc, Coord size);

        [DllImport("kernel32.dll", SetLastError = true)]
        static extern void ClosePseudoConsole(IntPtr hpc);

        [DllImport("kernel32.dll", SetLastError = true)]
        static extern bool CreatePipe(out IntPtr hReadPipe, out IntPtr hWritePipe, IntPtr lpPipeAttributes, uint nSize);

        [DllImport("kernel32.dll", SetLastError = true)]
        static extern bool CloseHandle(IntPtr hObject);

        [DllImport("kernel32.dll", SetLastError = true)]
        static extern bool InitializeProcThreadAttributeList(IntPtr lpAttributeList, int dwAttributeCount, int dwFlags, ref IntPtr lpSize);

        [DllImport("kernel32.dll", SetLastError = true)]
        static extern bool UpdateProcThreadAttribute(IntPtr lpAttributeList, uint dwFlags, IntPtr attribute, IntPtr lpValue, IntPtr cbSize, IntPtr lpPreviousValue, IntPtr lpReturnSize);

        [DllImport("kernel32.dll", SetLastError = true)]
        static extern bool DeleteProcThreadAttributeList(IntPtr lpAttributeList);

        [DllImport("kernel32.dll", SetLastError = true, CharSet = CharSet.Unicode)]
        static extern bool CreateProcess(string lpApplicationName, string lpCommandLine, IntPtr lpProcessAttributes, IntPtr lpThreadAttributes, bool bInheritHandles, uint dwCreationFlags, IntPtr lpEnvironment, string lpCurrentDirectory, ref STARTUPINFOEX lpStartupInfo, out PROCESS_INFORMATION lpProcessInformation);

        [DllImport("kernel32.dll", SetLastError = true)]
        static extern bool ReadFile(IntPtr hFile, byte[] lpBuffer, uint nNumberOfBytesToRead, out uint lpNumberOfBytesRead, IntPtr lpOverlapped);

        [DllImport("kernel32.dll", SetLastError = true)]
        static extern bool WriteFile(IntPtr hFile, byte[] lpBuffer, uint nNumberOfBytesToWrite, out uint lpNumberOfBytesWritten, IntPtr lpOverlapped);

        [DllImport("kernel32.dll", SetLastError = true)]
        static extern uint WaitForSingleObject(IntPtr hHandle, uint dwMilliseconds);

        [DllImport("kernel32.dll", SetLastError = true)]
        static extern bool GetExitCodeProcess(IntPtr hProcess, out uint lpExitCode);

        [DllImport("kernel32.dll", SetLastError = true)]
        static extern bool TerminateProcess(IntPtr hProcess, uint uExitCode);
    }
}
