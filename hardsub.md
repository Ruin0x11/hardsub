hardsub(1) -- burn soft subtitles into video
============================================

## SYNOPSIS

`hardsub` [ `options` ] <`input`>


## DESCRIPTION

Subtitles in videos can come in two flavors: As a separate stream, rendered over the video while playback, or already included in the video image. The former variant (soft) can be deactivated or switched freely, which is not possible with the latter (hard). While conversion of soft subtitles into their hardcoded counterpart strips this choice, it makes the video file accessible on more devices: Not all players understand complex subtitle formats, especially these with elaborate effects. And some hardware may not be powerful enough to render them in real time.

This script prepares a file for these devices by re-encoding one soft subtitle stream of a given file into the video.


## OPTIONS

  - `-h`:
    Show a summary of the options.

  - `-v`:
    Show the output of all short-running ffmpeg(1) subprocesses that are used to collect information about the video and extract streams and attachments. Without this option, only the encoding run is shown to report encoding progress.

  - `-s` _stream_:
    Select the subtitle stream to use. Only the streams containing subtitles are counted, not all streams included in the given input file, starting at 0. If the number does not denote any existent stream, ffmpeg will issue an error.

    The option alternatively accepts a name, which is interpreted as the title of a subtitle stream. If no subtitle has this name, this argument is regarded invalid and hardsub exits with an error.

    If this option is left out despite the input having multiple different subtitles to choose from, a warning will be issued.

  - `-l`:
    List available subtitle streams for the `-s` option, with their title and numbers. No encoding will take place and all other options are ignored.

  - `-o` _output_:
    Place the resulting video with the given file name.

    Without this option, the output file name will be the same as the input, with the marker *.hardsubbed* inserted just before the extension.

  - `-(` ... `-)`:
    To control how the video is created, options may be passed to the encoding ffmpeg(1) command by enclosing them in bracket arguments. Be aware that most shells like to interpret these as special characters and they thus most likely need to be escaped. Any argument found between them is passed to ffmpeg unaltered.

    For every opening one, there has to be a closing one. Nesting them is not supported.

    Arbitrary options can be passed, even ones that alter the filtergraph or mappings. However, they must be comaptible with the single input and output files, passed through as given to this program, as well as the filter already present to add the rendered subtitles into the video image. When no mapping is specified, ffmpeg by default will disregard all attachments and subtitle streams, only leaving audio and video streams in place.


## EXIT STATUS

Any error in option specification will lead to an exit code of 1.

When ffmpeg(1) runs to encode a video, its exit status is passed through. Note that re-encoding the video may take a long time.


## BUGS

This project was created by [XZS](mailto:d.f.fischer@web.de) and [lives at GitHub](http://github.com/dffischer/hardsub). Bugs can be filed in [the tracker found there](http://github.com/dffischer/hardsub/issues).


## SEE ALSO

ffmpeg(1), ffmpeg-filters(1).
