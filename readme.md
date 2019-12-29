GitFocus
========

*Automate entering GitHub & GitLab issues into OmniFocus*

To read more about the creation of GitFocus and how it works, see <https://nostodnayr.net/2019/12/gitfocus>.

Download the latest release from <https://github.com/nostodnayr/gitfocus/releases/latest>.

How the scripts work
--------------------

Together, the scripts perform four primary tasks:

1. Collect information about the web page from Safari.
2. Transform the page title into an action title.
3. *Based on your specifications*, determine which OmniFocus project the action is saved to.
4. Make the action in OmniFocus.


### Titling

The first Perl script called is the `titler`, which transforms a web page title like this:

> Update 'this thing' to 'that thing' and link to them from each (#8155) · Issues · content / web / support / en · GitLab

…into an action titled:

> resolve ❮#8155❯ – ‘Update 'this thing' to 'that thing' and link to them from each’

The ticket number goes at the front so that both it and the titles start in roughly the same position for each action, improving readability. The heavy angle brackets are there to help the issue numbers stand out to make them scannable.

If you want to change the verb, capitalisation or anything else about the action title, instructions can be found in the `gitfocus-titler.pl` file.


### Sorting

The resulting action gets sorted into a corresponding OmniFocus project based on the `sorter`. Beware, for it to work, **it must be configured**.

Full instructions for how to set up the sorter are in the `gitfocus-sorter.pl` file. In short, the script checks if a search string is in the page title. If found, the project name is passed back to the AppleScript. For the current example, I’d use the following to save the action to the *Support Pages* project in OmniFocus:

	print "Support Pages" if $page_title =~ m`content / web / support`;


### Action Creation

All being well, once the script has all the information it needs, it will make the action and save it to the project as specified. If the script is called on a page that’s not GitHub or GitLab, or if it fails to recognise the site correctly, the new action is dropped in the quick entry window.