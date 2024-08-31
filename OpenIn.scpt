on run {input, parameters}
    -- Check if the input is not empty and is a list
    if (count of input) is greater than 0 then
        set theFile to item 1 of input
        set filePath to POSIX path of theFile
        set fileDir to POSIX path of (do shell script "dirname " & quoted form of filePath)
        
        -- Check if the file is in a Git repository
        set gitCommand to "cd " & quoted form of fileDir & " && git rev-parse --is-inside-work-tree"
        set isGitRepo to do shell script gitCommand
        
        if isGitRepo is "true" then
            -- Get the root directory of the Git repository
            set gitCommand to "cd " & quoted form of fileDir & " && git rev-parse --show-toplevel"
            set repoRoot to do shell script gitCommand
            
            -- Compute the relative path of the file
            set relativeFilePath to do shell script "cd " & quoted form of repoRoot & " && cd " & quoted form of fileDir & " && echo $(pwd)/$(basename " & quoted form of filePath & ") | sed 's|" & repoRoot & "/||'"
            
            -- Get the latest commit hash for the file
            set gitCommand to "cd " & quoted form of fileDir & " && git log -n 1 --pretty=format:%H -- " & quoted form of filePath
            set commitHash to do shell script gitCommand
            
            -- Get the remote origin URL
            set gitCommand to "cd " & quoted form of fileDir & " && git config --get remote.origin.url"
            set originURL to do shell script gitCommand
            
            -- Convert the origin URL to HTTPS format if necessary
            if originURL starts with "git@github.com:" then
                set originURL to "https://github.com/" & (text 16 thru -1 of originURL)
                set originURL to text 1 thru -5 of originURL -- Remove the ".git" at the end
            else if originURL ends with ".git" then
                set originURL to text 1 thru -5 of originURL -- Remove the ".git" at the end
            end if
            
            -- Construct the URL
            set fileURL to originURL & "/blob/" & commitHash & "/" & relativeFilePath
            
            -- Open the URL in the default web browser
            do shell script "open " & quoted form of fileURL
        else
            display dialog "The file path is: " & filePath & "\nThis file is not in a Git repository."
        end if
    else
        display dialog "No file selected."
    end if
    return input
end run

-- Helper function to replace text
on replaceText(find, replace, textString)
    set AppleScript's text item delimiters to find
    set textItems to every text item of textString
    set AppleScript's text item delimiters to replace
    set newString to textItems as string
    set AppleScript's text item delimiters to ""
    return newString
end replaceText
