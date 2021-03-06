property needSetup : true

property alphaValue : 0.5
property defaultalphaValue : 0.5
property blurRadius : 8
property defaultblurRadius : 8

property msg0 : "select"
property buttonList0 : {"Use default setting", "Change custom setting"}

property msg1 : "Input alphaValue（0 =< alphaValue =< 1）"
property msg2 : "Input blurRadius（0 =< blurRadius）"

property msg3 : "Convert file format after process?"
property buttonList3 : {"Yes", "No"}
property msg5 : "Select file format"
property buttonList5 : {"gif", "png", "jpeg"}
property convertImage : false
property convertImageformat : "jpeg"

property msg4 : "Open files by ImageOptim.app after process?"
property buttonList4 : {"Yes", "No"}
property useImageOptim : false

on open drop
	mainScript(drop)
end open

on run
	set drop to choose file with multiple selections allowed
	mainScript(drop)
end run

on mainScript(drop)
	set unixPathShadow to settingShadowPath()
	
	if needSetup then
		runSetup()
	end if
	
	repeat with theFile in drop
		if gazou(theFile) then
			set fpath to theFile's POSIX path
			
			if fpath does not contain "-shadow" then --block loop
				
				set fname_ext to do shell script "n=" & fpath's quoted form & ";echo \"${n##*/}\""
				
				set fname to do shell script "n=" & fname_ext's quoted form & ";echo \"${n%.*}\""
				
				set fext to do shell script "n=" & fpath's quoted form & ";echo \"${n##*.}\""
				
				set fdir to do shell script "n=" & fpath's quoted form & ";echo \"${n%/*}\""
				
				do shell script quoted form of unixPathShadow & " -a " & alphaValue & " -b " & blurRadius & " " & quoted form of fpath
				
				set basePath to fdir & "/" & fname & "-shadow-a" & (alphaValue as text) & "-b" & (blurRadius as text) & "."
				--"/Users/hoge/name-shadow-a0.5-b8."
				set addedShadowPath to basePath & fext
				--"/Users/hoge/name-shadow-a0.5-b8.jpg"
				
				if convertImage then
					set iext to fext
					
					if iext = "jpg" then
						set iext to "jpeg"
					end if
					
					set aext to convertImageformat
					
					if aext = "jpeg" then
						set aext to "jpg"
					end if
					
					
					set beforeaddedShadowPath to addedShadowPath
					set addedShadowPath to basePath & aext
					
					if iext is not convertImageformat then
						do shell script "sips -s format " & convertImageformat & " " & quoted form of beforeaddedShadowPath & " --out " & quoted form of addedShadowPath
						delay 0.5
						
						do shell script "rm " & quoted form of beforeaddedShadowPath
					end if
					
				end if
				
				if useImageOptim then
					do shell script "open -a ImageOptim " & quoted form of addedShadowPath
				end if
			end if
		end if
	end repeat
	
end mainScript

on runSetup()
	set userInput to ddb(msg0, buttonList0)
	
	if userInput = item 1 of buttonList0 then
		set alphaValue to defaultalphaValue
		set blurRadius to defaultblurRadius
		set convertImage to false
		set useImageOptim to false
	else if userInput = item 2 of buttonList0 then
		set alphaValue to 2
		
		repeat until 0 ≤ alphaValue and alphaValue ≤ 1
			
			set alphaValue to dda(msg1, defaultalphaValue)
			
			if numChkKai(alphaValue) = false then
				set alphaValue to 2
			end if
			
		end repeat
		
		set blurRadius to -1
		
		repeat until 0 ≤ blurRadius
			
			set blurRadius to dda(msg2, defaultblurRadius)
			
			if numChkKai(blurRadius) = false then
				set blurRadius to -1
			end if
			
		end repeat
		
		set userInput to ddb(msg3, buttonList3)
		
		if userInput = item 1 of buttonList3 then
			set convertImage to true
			
			set convertImageformat to ddb(msg5, buttonList5)
			
		else if userInput = item 2 of buttonList3 then
			set convertImage to false
		end if
		
		set userInput to ddb(msg4, buttonList4)
		
		if userInput = item 1 of buttonList4 then
			set useImageOptim to true
		else if userInput = item 2 of buttonList4 then
			set useImageOptim to false
		end if
		
	end if
	
	set needSetup to false
end runSetup

on settingShadowPath()
	
	set macPathShadow to path to resource "shadow"
	set unixPathShadow to macPathShadow's POSIX path
	
	return unixPathShadow
	
end settingShadowPath

on dda(msg, defaultAnswer)
	display dialog msg default answer defaultAnswer buttons {"OK"} default button 1
	return text returned of result
end dda

on ddb(msg, buttonList)
	display dialog msg as text buttons buttonList default button length of buttonList
	return button returned of result
end ddb

on numChkKai(aNum)
	
	if aNum is "" then
		return false
	else
		numChk(aNum)
	end if
	
end numChkKai

on numChk(aNum)
	set aClass to (class of aNum) as string
	if aClass = "number" or aClass = "double" or aClass = "integer" or aClass = "real" then
		return true
	else if aClass = "string" or aClass = "text" or aClass = "unicode text" then
		try
			set bNum to aNum as number
			return true
			
		on error
			return false
		end try
	end if
end numChk

on getModifierKeys()
	set theRubyScript to "require 'osx/cocoa';
event=OSX::CGEventCreate(nil);
mods=OSX::CGEventGetFlags(event);
print mods,' ';
print 'shift ' if (mods&0x00020000)!=0;
print 'control ' if(mods&0x00040000)!=0;
print 'option ' if(mods & 0x00080000)!=0;
print 'command ' if(mods & 0x00100000)!=0;
"
	return do shell script "/usr/bin/ruby -e " & quoted form of theRubyScript
end getModifierKeys

on gazou(theFile) --画像かどうか判別
	set x to {"jpg", "gif", "png", "tiff", "bmp"}
	
	tell application "Finder"
		get name extension of theFile
	end tell
	
	if x contains result then
		return true
	else
		return false
	end if
	
end gazou