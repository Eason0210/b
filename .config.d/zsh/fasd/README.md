# Fasd

Fasd is a tool for quick access to files for POSIX shells. It is inspired by
tools like `autojump`(https://github.com/joelthelion/autojump),
`z`(http://github.com/rupa/z) and `v`(https://github.com/rupa/v). Fasd keeps
track of files you have accessed, so that you can quickly reference them in the
command line.

The name fasd comes from the default suggested aliases `f`(files),
`a`(files/directories), `s`(show/search/select), `d`(directories).

Fasd ranks files and directories by "frecency," that is, by both "frequency" and
"recency." The term "frecency" was first coined by Mozilla and used in Firefox
([link](https://developer.mozilla.org/en/The_Places_frecency_algorithm)).

Fasd uses [Bayesian Inference](https://en.wikipedia.org/wiki/Bayesian_inference)
and [Bayesian Ranking](https://github.com/clvv/fasd/wiki/Bayesian-Ranking) to rank
files and directories for a set of given matching patterns. "Frecency" is used
as the prior probability distribution, and a simple algorithm is used to
calculate the likelihood of the given set of patterns.

# A Note for Early Adopters

Fasd was originally named `f`. `f` was renamed to fasd for various reasons. And
the latest release contains many improvements compared to old master branch of
`f`, most importantly fasd acquired the ability to be run as an executable
(instead of as a shell function, which is comparably slower). Previous f users
please update all of your f-related configurations accordingly. And don't
forget to rename your database file:

```sh
mv "$HOME/.f" "$HOME/.fasd"
```

# Introduction

If you're like me, you use your shell to navigate and launch applications. Fasd
helps you do that more efficiently. With fasd, you can open files regardless of
which directory you are in. Just with a few key strings, fasd can find
a "frecent" file or directory and open it with command you specify. Below are
some hypothetical situations, where you can type in the command on the left and
fasd will "expand" your command into the right side. Pretty magic, huh?

```
  v def conf       =>     vim /some/awkward/path/to/type/default.conf
  j abc            =>     cd /hell/of/a/awkward/path/to/get/to/abcdef
  m movie          =>     mplayer /whatever/whatever/whatever/awesome_movie.mp4
  o eng paper      =>     xdg-open /you/dont/remember/where/english_paper.pdf
  vim `f rc lo`    =>     vim /etc/rc.local
  vim `f rc conf`  =>     vim /etc/rc.conf
```

Fasd comes with four useful aliases by default:

```sh
alias a='fasd -a' # any
alias s='fasd -s' # show / search / select
alias d='fasd -d' # directory
alias f='fasd -f' # file
alias z='fasd_cd -d' # cd, same functionality as j in autojump
```

Fasd will smartly detect when to display a list of files or just the best
match. For instance, when you call fasd in a subshell with some search
parameters, fasd will only return the best match. This enables you to do:

```sh
mv update.html `d www`
cp `f mov` .
```

# Install

Fasd is available in various package managers. Please check
[the wiki page](https://github.com/clvv/fasd/wiki/Installing-via-Package-Managers)
for an up-to-date list.

You can also manually obtain a copy of fasd.

Download fasd 0.5.4 from GitHub:
[zip](https://github.com/clvv/fasd/zipball/0.5.4),
[tar.gz](https://github.com/clvv/fasd/tarball/0.5.4).

Fasd is a self-contained POSIX shell script that can be either sourced or
executed. A Makefile is provided to install `fasd` and `fasd.1` to desired
places.

System-wide install:

    make install

Install to $HOME:

    PREFIX=$HOME make install

Or alternatively you can just copy `fasd` to anywhere you like (preferably
under some directory in `$PATH`).

To get fasd working in a shell, some initialization code must be run. Put the
line below in your shell rc.

```sh
eval "$(fasd --init auto)"
```

This will setup a command hook that executes on every command and advanced tab
completion for zsh and bash.

If you want more control over what gets into your shell environment, you can
pass customized set of arguments to `fasd --init`.

```
zsh-hook             # define _fasd_preexec and add it to zsh preexec array
zsh-ccomp            # zsh command mode completion definitions
zsh-ccomp-install    # setup command mode completion for zsh
zsh-wcomp            # zsh word mode completion definitions
zsh-wcomp-install    # setup word mode completioin for zsh
bash-hook            # add hook code to bash $PROMPT_COMMAND
bash-ccomp           # bash command mode completion definitions
bash-ccomp-install   # setup command mode completion for bash
bash-wcomp           # bash word mode completion definitions (experimental)
bash-wcomp-install   # setup word mode completion for bash (experimental)
posix-alias          # define alias that applies to all posix shells
posix-hook           # setup $PS1 hook for shells that's posix compatible
```

Example for a minimal zsh setup (no tab completion):

```sh
eval "$(fasd --init posix-alias zsh-hook)"
```

Optionally, if you can also source `fasd` if you want `fasd` to be a shell
function instead of an executable.

You can tweak initialization code. For instance, if you want to use "c"
instead of "z" to do directory jumping. You run the code below:

```sh
# function to execute built-in cd
fasd_cd() { [ $# -gt 1 ] && cd "$(fasd -e echo "$@")" || fasd "$@"; }
alias c='fasd_cd -d' # `-d' option present for bash completion
```

After you first installed fasd, open some files (with any program) or `cd`
around in your shell. Then try some examples below.

# Examples

```sh
f foo # list recent files mathcing foo
a foo bar # list recent files and directories mathcing foo and bar
f -e vim foo # run vim on the most frecent file matching foo
mplayer `f bar` # run mplayer on the most frecent file matching bar
z foo # cd into the most frecent directory matching foo
open `sf pdf` # interactively select a file matching pdf and launch `open`
```

You should add your own aliases to fully utilize the power of fasd. Here are
some examples to get you started:

```sh
alias v='f -e vim' # quick opening files with vim
alias m='f -e mplayer' # quick opening files with mplayer
alias o='a -e xdg-open' # quick opening files with xdg-open
```

If you're using bash, you have to call `_fasd_bash_hook_cmd_complete` to make
completion work. For instance:

    _fasd_bash_hook_cmd_complete v m j o

You could select an entry in the list of matching files.

# How It Works

When you source `fasd`, fasd adds a hook which will be executed whenever you
execute a command. The hook will scan your commands' arguments and determine if
any of them refer to existing files or directories. If yes, fasd will add them
to the database.

When you run `fasd` with search arguments, fasd uses [Bayesian
Ranking](https://github.com/clvv/fasd/wiki/Bayesian-Ranking) to find the best
match.

# Compatibility

Fasd's basic functionalities are POSIX compliant, meaning that you should be
able to use fasd in all POSIX compliant shells. Your shell need to support
command substitution in `$PS1` in order for fasd to automatically track your
commands and files. This feature is not specified by the POSIX standard, but
it's nonetheless present in many POSIX compliant shells. In shells without
prompt command or prompt command substitution (tcsh for instance), you can add
entries manually with `fasd -A`. You are very welcomed to contribute shell
initialization code for not yet supported shells.

Fasd has been tested on the following shells: bash, zsh, mksh, pdksh, dash,
busybox ash, FreeBSD 9 /bin/sh and OpenBSD /bin/sh.

# Synopsis

    fasd [options] [query ...]
      options:
        -s         show list of files with their ranks
        -l         list paths only
        -i         interactive mode
        -e <cmd>   set command to execute on the result file
        -b <name>  only use <name> backend
        -B <name>  add additional backend <name>
        -a         match files and directories
        -d         match directories only
        -f         match files only
        -r         match by rank only
        -t         match by recent access only
        -h         show a brief help message

# Tab Completion

Fasd offers two completion modes, command mode completion and word mode
completion.

Command mode completion is just like completion for any other commands. It is
triggered when you hit tab on a `fasd` command or its aliases. Under this mode
your queries can be separated by a space. Tip: if you find that the completion
result overwrites your queries, type an extra space before you hit tab.

Word mode completion can be triggered on *any* command. Word completion is
triggered by any command line argument that starts with `,` (all), `f,`
(files), or `d,` (directories), or that ends with `,,` (all), `,,f` (files), or
`,,d` (directories). Examples:

    $ vim ,rc,lo<Tab>
    $ vim /etc/rc.local

    $ mv index.html d,www<Tab>
    $ mv index.html /var/www/

If you use zsh, word completion is enabled by default. There are also three zle
widgets: `fasd-complete`, `fasd-complete-f`, `fasd-complete-d`. You can bind
them to keybindings you like:

```sh
bindkey '^X^A' fasd-complete    # C-x C-a to do fasd-complete (fils and directories)
bindkey '^X^F' fasd-complete-f  # C-x C-f to do fasd-complete-f (only files)
bindkey '^X^D' fasd-complete-d  # C-x C-d to do fasd-complete-d (only directories)
```

If you use bash, you can turn on this *experimental feature* by executing
`eval "$(fasd --init bash-wcomp bash-wcomp-install)"` after sourcing `fasd`
*and* after any bash completion setup. This will alter your existing completion
setup, so you might get a *broken* completion system.

# Backends

Fasd can take advantage of different sources of recent / frequent files. Most
desktop environments (like Gtk) and some editors (like Vim) keep a list of
accessed files. Fasd can use them as additional backends if the data can be
converted into fasd's native format. As of now, fasd supports Gtk's
`recently-used.xbel` and Vim's `viminfo` backends. You can define your own
backend by declaring a function by that name in your `.fasdrc`. You set default
backend with `_FASD_BACKENDS` variable in our `.fasdrc`.

Fasd can mimic [v](http://github.com/rupa/v)'s behavior by this alias:

```sh
alias v='f -e vim -b viminfo'
```

# Tweaks

Some shell variables that you can set before sourcing `fasd`. You can set them
in `$HOME/.fasdrc`

```
$_FASD_DATA
Path to the fasd data file, default "$HOME/.fasd".

$_FASD_BLACKLIST
List of blacklisted strings. Commands matching them will not be processed.
Default is "--help".

$_FASD_SHIFT
List of all commands that needs to be shifted, defaults to "sudo busybox".

$_FASD_IGNORE
List of all commands that will be ignored, defaults to "fasd cd ls echo".

$_FASD_TRACK_PWD
Fasd defaults to track your "$PWD". Set this to 0 to disable this behavior.

$_FASD_AWK
Which awk to use. Fasd can detect and use a compatible awk.

$_FASD_SINK
File to log all STDERR to, defaults to "/dev/null".

$_FASD_MAX
Max total score / weight, defaults to 2000.

$_FASD_SHELL
Which shell to execute. Some shells will run faster than others. fasd
is faster with ksh variants.

$_FASD_BACKENDS
Default backends.
```

# Debugging

If fasd does not work as expected, please file a bug report describing the
unexpected behavior along with your OS version, shell version, awk version, sed
version, and a log file.

You can set `_FASD_SINK` in your `.fasdrc` to obtain a log.

```sh
_FASD_SINK="$HOME/.fasd.log"
```

# COPYING

Fasd is originally written based on code from [z](https://github.com/rupa/z) by
rupa deadwyler under the WTFPL license. Most if not all of the code has been
rewritten. Fasd is licensed under the "MIT/X11" license.

