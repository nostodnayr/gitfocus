------------------------------------------------------------------------------------------
--
-- GitFocus
-- 
-- by:
--  - Ryan Dotson:       original scripts, editing and documentation
--  - Rosemary Orchard:  issue content and author extraction, 'Show in OmniFocus'
--
-- Version 1.1
-- 12 January 2020
--
-- <https://github.com/nostodnayr/gitfocus>
--
-- This script takes a GitLab/GitHub issue or merge request open in front Safari window
-- and creates an action in OmniFocus with a note including a link and the text of
-- the item.
--
-- This AppleScript relies on two Perl scripts to get the work done. They are:
--
--    + gitfocus-sorter.pl: Determines which project the action is sorted into
--    + gitfocus-titler.pl: Prettifies the action title
--
-- IMPORTANT
-- You must edit the sorter script to suit your needs. Instructions for doing
-- so can be found in that script.
--
-- To use, copy all three scripts to ~/Library/Scripts/Applications/Safari/
-- I trigger the script with a keyboard shortcut assigned through FastScripts
-- (to the AppleScript, not the Perl scripts).
--
-- The script will try to handle itself gracefully, and if the item doesn't match
-- a project you've specified or isn't a GitLab/Hub page, it should open the Quick Entry
-- window with the page information filled.
--
-- Known Limitations: - The script may behave unexpectedly if you have multiple projects
--                      with the same name.
--                    - Author name and issue text may fail if GitLab or GitHub change
--                      their markup.
------------------------------------------------------------------------------------------

tell front document of application "Safari"
	set _page_title to the name as string
	set _page_url to the URL
	
	-- Do a rudimentary check of which site we're dealing with.
	-- We will try to be robust in handling GitLab pages as we proceed.
	if _page_url contains "gitlab" then
		set _flavour to "gitlab"
	else if _page_url contains "github" then
		set _flavour to "github"
	else
		set _flavour to "unknown"
	end if
	
	-- If this isn't GitHub, we assume it's GitLab because some instances may not be
	-- running at URLs that actually contain the string 'gitlab'.
	if _flavour is "github" then
		set _issue_content to ¬
			do JavaScript "x = document.getElementsByClassName('d-block comment-body markdown-body js-comment-body')[0].innerText.trim();"
	else
		set _issue_content to ¬
			do JavaScript "x = document.getElementsByClassName('description js-task-list-container is-task-list-enabled')[0].innerText.trim();"
	end if
	
	if _flavour is "github" then
		set _issue_author to ¬
			do JavaScript "x = document.getElementsByClassName('author text-bold link-gray')[0].innerText;"
	else
		set _issue_author to ¬
			do JavaScript "x = document.getElementsByClassName('author-link')[0].innerText;"
	end if
end tell

-- Build the note content bit by bit so that if we are missing any data
-- we can be somewhat informative about it.
try
	set _action_note to _page_url & return
end try

try
	set _action_note to _action_note & "Created by: " & _issue_author & return & return
on error
	set _action_note to _action_note & "(Could not determine issue author.)" & return & return
end try

try
	set _action_note to _action_note & _issue_content
on error
	set _action_note to _action_note & "(Could not determine the issue content automatically.)"
end try

try
	set _action_title to ¬
		do shell script "perl ~/Library/Scripts/Applications/Safari/gitfocus-titler.pl " & ¬
			quoted form of _page_title & ¬
			" " & _flavour
on error errMsg number eNum
	display alert ¬
		"Couldn’t run the GitFocus Titler" message "The script will try to continue. You may need to adjust the action title manually." & return & return & ¬
		"Error " & eNum & ": " & errMsg
	set _action_title to "**NOT MATCHED**"
end try

try
	set _project_sort to ¬
		do shell script "perl ~/Library/Scripts/Applications/Safari/gitfocus-sorter.pl " & quoted form of _page_title
on error errMsg number eNum
	display alert "Couldn’t run the GitFocus Sorter" message "The script will try to continue. You many need to file the action manually." & return & return & ¬
		"Error " & eNum & ": " & errMsg
	set _project_sort to ""
end try

tell application "OmniFocus"
	try
		tell default document
			if (_action_title is "**NOT MATCHED**") or (_project_sort is "") then
				tell quick entry
					activate
					make new inbox task with properties {name:_page_title, note:_page_url}
					open
				end tell
			else
				tell (first flattened project where its name is _project_sort)
					set _action to make new task with properties {name:_action_title, note:_action_note}
				end tell
				
				-- display the alert in Safari so we don't have to switch to OmniFocus
				tell application "Safari"
					set _alert_heading to "Action Created in " & _project_sort
					set _alert_result to display alert _alert_heading message _action_title ¬
						buttons {"Show in OmniFocus", "OK"} default button "OK" giving up after 5
				end tell
				
				if button returned of _alert_result is "Show in OmniFocus" then
					GetURL "omnifocus:///task/" & the id of _action
					-- if you would prefer the action be displayed in a new window, comment
					-- out the 'GetURL' line above and uncomment the following 'tell' line:
					-- tell (make new document window) to GetURL "omnifocus:///task/" & the id of _action
					activate
				end if
			end if
		end tell
	on error errMsg number eNum
		tell application "OmniFocus"
			activate
			display alert eNum message errMsg
		end tell
	end try
end tell
