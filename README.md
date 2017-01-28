Quick and Nimble Acceptance Tests
==================================

High-level tests that exercises [Quick](https://github.com/Quick/Nimble) &
[Nimble](https://github.com/Quick/Nimble) as a dependency though common
supported configurations. This helps verify if changes to Nimble configurations
break consumers of Nimble as well as providing an example configuration of
Nimble in its various configurations.

Current testing configurations:

- iOS, Test Bundle
- iOS, UI Test Bundle
- iOS, Without XCTest (in app; Nimble Only)
- macOS, Test Bundle
- macOS, UI Test Bundle
- macOS, Without XCTest (in app; Nimble Only)
- tvOS, Without XCTest (in app; Nimble Only)
- tvOS, Test Bundle
- tvOS, UI Test Bundle

Setup
-----

Clone this repository. Install `colorize` in one of two ways:

```
bundle install # if you have bundler
gem install 'colorize' # or directly install the only dependency
```

Running
-------

**Note:** Can only be run on OS X versions that support UI Testing (10.11+)

To run locally, clone this repository and then run:

```bash
# Downloads Quick & Nimble locally for testing
rake vendor

# Runs all configurations
rake
```

If you prefer, you can change `Vendor/Nimble` to point to a branch of Nimble if
you want to see how your changes affect these configurations.

`vendor:nimble` rake task supports optional configuration arguments to change the source of Nimble:

```bash
rake 'vendor_nimble[http://github.com/user/Nimble-Fork.git,my-branch]'
```

Likewise for Quick:

```bash
rake 'vendor:quick[http://github.com/user/Quick-Fork.git,my-branch]'
```

If you want to clean Xcode derived data, use `rake clean`.

Finally, since this is rake, you can combine them all:

```bash
# clean, then download quick & nimble before running tests
rake clean vendor default
```

Notes
-----

**Why not use submodules?**

Carthage has a [bug](https://github.com/Carthage/Carthage/issues/135) that
prevents submoduling Nimble in this repository, so the rakefile will
dynamically fetch it instead.

