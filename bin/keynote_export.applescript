on sansExt(theFileName)
  do shell script "file=" & theFileName & ";" & "echo ${file%.*}"
end sansExt

on getExt(theFileName)
  do shell script "file=" & theFileName & ";" & "echo ${file##*.}"
end getExt

on run argv
  set keynote_path to (item 1 of argv)
  set out_path to (item 2 of argv)
  set extension to getExt(out_path)
  set basename to sansExt(out_path)

  tell application "Keynote"
    set keynote_file to open (keynote_path as POSIX file)
    if extension is equal to "pdf" then
      export keynote_file to (out_path as POSIX file) as PDF
    else if extension is equal to "jpeg" then
      export keynote_file to (basename as POSIX file) as slide images with properties { compression factor: 1.0, image format: JPEG }
    else
      do shell script "echo Output format " & extension & " not supported."
    end
  end tell
end run
