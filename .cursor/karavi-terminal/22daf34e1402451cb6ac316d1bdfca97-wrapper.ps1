param([string]$PipeBase)
while ($true) {
  $request = [System.IO.Pipes.NamedPipeServerStream]::new("$PipeBase-request", [System.IO.Pipes.PipeDirection]::In)
  $request.WaitForConnection(); $reader = [System.IO.StreamReader]::new($request); $payload = $reader.ReadLine(); $reader.Dispose(); $request.Dispose()
  if ($payload -eq '__close__') { break }
  $result = [ordered]@{ status='completed'; stdout=''; stderr=''; nativeExitCode=$null; powerShellSucceeded=$true; timedOut=$false }
  try { $items = & ([scriptblock]::Create([Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($payload)))) 2>&1; foreach ($item in $items) { if ($item -is [System.Management.Automation.ErrorRecord]) { $result.stderr += ($item.ToString()+[Environment]::NewLine) } else { $result.stdout += ($item | Out-String) } }; $result.nativeExitCode=$global:LASTEXITCODE } catch { $result.status='failed'; $result.powerShellSucceeded=$false; $result.stderr=$_.ToString() }
  $response = [System.IO.Pipes.NamedPipeServerStream]::new("$PipeBase-response", [System.IO.Pipes.PipeDirection]::Out)
  $response.WaitForConnection(); $writer = [System.IO.StreamWriter]::new($response); $writer.AutoFlush=$true; $writer.WriteLine(($result | ConvertTo-Json -Compress)); $writer.Dispose(); $response.Dispose()
}