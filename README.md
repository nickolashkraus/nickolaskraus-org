# [nickolaskraus.org](https://nickolaskraus.org/)

[![MIT license](https://img.shields.io/badge/License-MIT-blue.svg)](https://github.com/NickolasHKraus/nickolaskraus-org/blob/master/LICENSE)

[nickolaskraus.org](https://nickolaskraus.org/) is my personal website. It is generated using [Hugo](https://gohugo.io/) and hosted on [AWS](https://aws.amazon.com/).

## Development

Initialize and update submodules:

```bash
git submodule init
git submodule update
```

### Git Submodules

The `git submodule update` command fetches the commit specified in `.git/modules` for each submodule of the parent Git repository. In order to update a submodule to the latest commit available from its remote reference, you will need to pull it directly:

```bash
cd <path/to/submodule>
git pull origin master
cd <path/to/parent>
git add . && git commit -m "Update submodules"
```

### Hugo

Currently, this repository is pinned to Hugo v0.55.4 due to a rendering [issue](https://github.com/gohugoio/hugo/issues/6040) of lists with code blocks introduced in Hugo v0.55.5.

To install Hugo v0.55.4 via `go get`:

```bash
# remove symlinks for Hugo formula
brew unlink hugo

# install Hugo via `go get`
go get -v github.com/gohugoio/hugo

# checkout version v0.55.4
cd $GOPATH/src/github.com/gohugoio/hugo
git checkout v0.55.4
go install

# confirm version
hugo version
```
