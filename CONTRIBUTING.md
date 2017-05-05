## Contributing guidelines

### General community guidelines.
These apply everywhere, in the code, in the Issues/Pull Requests and in the commit messages.

Rule 0 of the internet applies. "Don't be a dick."

- Racial slurs will not be tolerated. If you cannot make your point without including slurs, don't make it at all.
- Remain peaceful in discussion. Don't start up unneeded garbage.
- Be polite.
- Contributors (those with push access) have the last word.
- No support is given for the following systems:
   - Ubuntu under Windows 10 shell
   - Mac OS X

You may be asked to change your wording in commit messages before submitting them.

### Pull Request rules

These are code guidelines that should be followed for PRs and forks in general.

- Don't add shellcheck exceptions. The project uses shellcheck to ensure that the bash code is properly formatted. The only allowed exception is for `cat` delimiters.
- Properly document your additions. If you add a new flag, add it to the usage line and to the manpage.ronn file in the docs folder. Then run build.sh inside the docs folder.
- If you use this project in a commercial project, remove 2dsamplevideo.mp4 . This file is licensed under CC-BY-NC 3.0. For more details, see files/2dsamplevideo.md .

PRs usually have their commits squashed in the merge if it is a large amount of commits. Minor commits usually do not get squashed.
