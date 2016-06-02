#!/usr/bin/php
 
$output = array();
$return = 0;
exec('git rev-parse --verify HEAD', $output, $return);
 
// Get GIT revision
$against = $return == 0 ? 'HEAD' : '';
 
// Get the list of files in this commit.
exec("git diff-index --cached --name-only {$against}", $output);
 
// Pattern to identify the files that need to be run with phpcs and php lint
$filename_pattern = '/\.(php|module|inc|install)$/';
$exit_status = 0;
 
// Loop through files.
foreach ($output as $file) {
    if ( ! preg_match($filename_pattern, $file)) {
        // don't check files that don't match the pattern
        continue;
    }
 
    // If file is removed from git do not sniff.
    if ( ! file_exists($file))
    {
        continue;
    }
 
    $lint_output = array();
    // Run the sniff
    exec("phpcs --standard=Drupal " . escapeshellarg($file), $lint_output, $return_phpcs);
    // Run php lint
    exec("php -l " . escapeshellarg($file), $lint_output, $return_lint);
 
    if (($return_phpcs == 0) && ($return_lint == 0)) {
        continue;
    }
    echo implode("\n", $lint_output), "\n";
    $exit_status = 1;
}
 
exit($exit_status);
