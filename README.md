# hardsub

A simple script to burn subtitles into video. It was written to prepare complex videos with styled subtitles and esoteric codecs for playback on devices with low processor power or restricted software, particularly ARM with Android.

Pass it a video file and it will use [ffmpeg](http://ffmpeg.org/) to re-encode the video with subtitles included.


## Installation

The script can be run directly from the checked out repository. For more options, see the [manual page](hardsub.md).

The latter may be installed along using [ronn](https://github.com/rtomayko/ronn). On distributions where these do not come included, [ffmpeg](http://ffmpeg.org/), [bash](http://tiswww.case.edu/php/chet/bash/bashtop.html), [grep](https://www.gnu.org/software/grep/), [pcre](http://www.pcre.org/) and [realpath](https://www.gnu.org/software/coreutils/) may have to be installed.

[Arch Linux](https://archlinux.org/) users can install [a package from the AUR](http://aur.archlinux.org/packages/hardsub-git/). It can also be built from the [PKGBUILD](PKGBUILD) as it is kept in this repository using [the makepkg-template for git](https://github.com/dffischer/git-makepkg-template).
