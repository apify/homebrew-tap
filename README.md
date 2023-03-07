# Apify Homebrew Tap

## What is Homebrew?

A package manager for macOS (or Linux), see more at <https://brew.sh>.

## What is a Tap?

A third-party (in relation to Homebrew) repository
providing installable packages (formulae) on macOS and Linux.

See more at <https://docs.brew.sh/Taps>

## How do I install packages from here?

```sh
brew install apify/tap/<PACKAGE_NAME>
```

You can also only add the tap which makes formulae within it
available in search results (`brew search` output):

```sh
brew tap apify/tap
```

## What packages are available?

Currently, only the [Apify CLI](https://docs.apify.com/apify-cli) is available in this tap:

```sh
brew install apify/tap/apify-cli

apify create my-first-actor
```
