15629  brew install gh
15630  gh auth login
15631  gh status
15632  gh codespace list
15635  gh gist list
15636  gh pr list
15637  gh issue list
15638  gh workflow list
15639  git switch --create test-gh-cli
15641  history | grep -E "git|gh" | tail -n 100
15642  history | grep -E "git|gh" | tail -n 20 | gsed -e '0,/brew/d'
