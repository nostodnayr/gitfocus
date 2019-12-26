------------------------------------------------------------------------------------------
--
-- GitFocus
-- 
-- by:
--  - Ryan Dotson:       original scripts, editing and documentation
--  - Rosemary Orchard:  issue content and author extraction, 'Show in OmniFocus'
--
-- Version 3
-- 18 December 2019
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
-- The sorter script must be edited by you to suit your needs. Instructions for doing
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
--                    - If you are using a self-hosted GitLab instance that doesn't have
--                      'gitlab' in the URL, the script will not attempt to extract
--                      the author or title. Edit the _page_url conditional block below
--                      to suit your needs.
--                    - Author name and issue text may fail if GitLab or GitHub change
--                      their markup.
--
------------------------------------------------------------------------------------------

tell document 1 of application "Safari"
	set _page_title to the name as string
	set _page_url to the URL
	
	if _page_url contains "gitlab" then
		set _issue_content to do JavaScript "x = document.getElementsByClassName('description js-task-list-container is-task-list-enabled')[0].innerText;"
		set _issue_author to do JavaScript "x = document.getElementsByClassName('author-link')[0].innerText;"
	else if _page_url contains "github" then
		set _issue_content to do JavaScript "x = document.getElementsByClassName('d-block comment-body markdown-body  js-comment-body')[0].innerText;"
		set _issue_author to do JavaScript "x = document.getElementsByClassName('author text-bold link-gray')[0].innerText;"
	end if
	
	-- try to be graceful in failure
	try
		set _action_note to _page_url & return & "Created by: " & _issue_author & return & return & _issue_content
	on error
		set _action_note to _page_url & return & return & "(Issue author or text could not be determined, sorry. –r/r–)"
	end try
end tell

try
	set _action_title to ¬
		do shell script "perl ~/Library/Scripts/Applications/Safari/gitfocus-titler.pl '" & _page_title & "'"
on error errMsg number eNum
	display alert "Couldn’t run the GitFocus Titler" message "The script will try to continue. Stand by." & return & return & "Error " & eNum & ": " & errMsg
	set _action_title to "**NOT MATCHED**"
end try

try
	set _project_sort to ¬
		do shell script "perl ~/Library/Scripts/Applications/Safari/gitfocus-sorter.pl '" & _page_title & "'"
on error errMsg number eNum
	display alert "Couldn’t run the GitFocus Sorter" message "The script will try to continue. Stand by." & return & return & "Error " & eNum & ": " & errMsg
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
					set _alert_message to "Action Created in " & _project_sort
					set _alert_result to display alert _alert_message message _action_title ¬
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
