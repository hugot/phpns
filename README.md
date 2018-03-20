# phpns
Phpns is a command line interface for the management and indexation of namespaces in PHP
projects. It is written in bash and mainly makes use of grep to index the namespaces
and classes that are present in a directory. Using this index, Phpns can parse a PHP 
file and add missing use statements, complete Fully Qualified Names (FQN's) of 
namespaces and classes, and more!

## Phpns in action
![phpns in action](https://cloud.hugot.nl/public/phpns/phpns_high.gif)


## Installation

### With basher
The recommended way to install phpns is with [basher](https://github.com/basherpm/basher), the
package manager for bash. If installed correctly, basher will take care of adding argument completion
for phpns to your shell and including the executable in your PATH. Basher will also make updating to
the latest version trivial. You can install phpns with the following command:

`basher install --ssh hugot/phpns`


### Cloning
phpns does not have any dependencies except for `sed`, `grep`, `awk` and a couple of other tools that
should be readily available on most Linux systems. You can install phpns easily using git by following these steps:

1. `cd` into an empty directory you want phpns to be installed into.
2. Clone the repository into the directory: `git clone git@github.com:hugot/phpns.git .`
3. Add the bin directory of the  repository to your path and make it permanent:  
`printf 'export PATH="%s:$PATH"\n' "$(pwd)/bin" >> ~/.bashrc && source ~/.bashrc`
4. Source the completions file and make sure it gets sourced every time you start your shell:  
`printf "source '%s'\n" "$(pwd)/completions/phpns.bash" >> ~/.bashrc && source completions/phpns.bash`
5. Test your installation by running `phpns help`

#### You can automate this process with the following command
```bash
# Note: Don't forget to replace INSTALL_DIR with your actual installation directory here!
cd INSTALL_DIR && git clone git@github.com:hugot/phpns.git . \
    && printf 'export PATH="%s:$PATH"\nsource '"'%s'"'\n' "$(pwd)/"{bin,completions/phpns.bash} >> ~/.bashrc \
    && source ~/.bashrc
```

## Usage

### Commands and options
Phpns puts an array of commands at your disposal that allow you to query information about namespaces
and classes that are available in your project. Aside from commands that provide information,
phpns also provides commands that manipulate files, like the "fix-uses" command.
Below you will find the output of `phpns help` as a brief overview of the commands and options available.

```
phpns - Resolve namespaces and fix missing use statements in your PHP scripts.
    
    USAGE:
        phpns COMMAND [ ARGUMENTS ] [ OPTIONS ]
    
    COMMANDS:
        ns,  namespace            FILE         Echo the namespace that is declared in FILE
        i,   index                             Index a project
        fu,  find-use             CLASS_NAME   Echo the FQN of a class
        fxu, fix-uses             FILE         Add needed use statements to FILE
        cns, classes-in-namespace NAMESPACE    Echo the classes that reside in NAMESPACE
        cmp, complete             WORD         Echo completions for FQN's that match WORD.
        fp,  filepath             FQN          Echo the filepath of the class by the name of FQN.

    TO BE IMPLEMENTED:
        rmuu, remove-unneeded-uses FILE: Remove all use statements for classes that are not being used.

    OPTIONS FOR ALL COMMANDS:
        -s --silent     Don't print info.
    
    UNIQUE OPTIONS PER COMMAND:
        namespace: -
        index:
            -d, --diff                Show differences between the files in the index and the files in the project directory.
            -N, --new                 Only index new files
        find-use:
            -j, --json                Provide possible use FQN's as a json array.
            -p, --prefer-own          If there are matches inside the "src" dir, only use those.
            -a, --auto-pick           Use first encountered match, don't provide a choice.
            -b. --bare                Print FQN's without any additives.
        fix-uses:
            -j, --json                Provide possible use FQN's per class as a json object with the class names as keys.
            -p, --prefer-own          If there are matches inside the "src" dir, only use those.
            -a, --auto-pick           Use first encountered match, for every class, don't provide a choice.
            -o, --stdout              Print to stdout in stead of printing to the selected file.
        complete:
            -e, --expand-classes      If no root namespaces match, expand FQN's for classes by the name of WORD
            -n, --no-classes          Only provide completions for namespaces.
            -c, --complete-classes    If no root namespaces match, provide FQN's for all (partially) matching classes.
        filepath: -

```

### Integration with other programs
A couple of phpns commands have a --json option, which will make them output information in JSON
format, this might prove useful if you are interested in integrating phpns with other applications.
Other commands will output data in a format that should be reasonably easy to parse, but if you do
run into problems with that, please do not hesitate to open an issue or maybe even open a pull request
so we can fix that problem for you.

### BASH Completion functions
If phpns has been installed correctly on your system, the completion functions in the `completions` directory of this repository
will be sourced into your shell, providing you with autocompletion functionality for phpns and its various commands.
A couple of these functions use phpns's `complete` command to complete FQN's of namespaces and classes in the 
current directory. These functions can also be used to complete FQN's for your own custom aliases, functions and programs.

#### An example
A thing that I find myself doing often on a day to day basis is opening php files from the command line. A function
that makes this a little less cumbersome and verbose would be a welcome addition to my workflow, so let's create one!  
I would like my function to be able to open files based on the FQN of the class that I provide as an argument. It is the classes
that I work with after all, and their location on my file system is not my primary concern. To resolve a FQN of a class to
the path of the file it was defined in, we can use the phpns `filepath` command. A bash function like this would do the
trick for me in this case:

```bash
# Note: I like to use vim, which is why it is in this example,
# but the trick would of course still work if you were to replace
# vim with nano, gedit or even vscode in this function.

pvim() {
    vim "$(phpns filepath "$1")"
}

```

This function will let me open the file in which the *App\Entity\Post* class is defined by typing
`pvim 'App\Entity\Post'`. That is still a little too verbose for my liking though. I prefer to type
as little as possible, so let's add some autocompletion to this function!

```bash
# Complete FQN's of classes for the pvim command
complete -o nospace -F __phpns_complete_expand_classes pvim

```

This will allow me to type `pvim Post<TAB>` and get `pvim App\\Entity\\Post` after which
I could hit ENTER and start editing the file. Nifty eh? And all of that with just 4 lines of bash!

#### Menu completion
The `__phpns_complete_expand_classes` completes FQN's for classes if a full class name is provided.
it would also be possible to use the `__phpns_complete_classes_expand_classes` function,
which would also complete partially matching class names, but that would
generate a lot of results, which bash's standard completion will not work well with.
If you do choose this route, consider enabling menu-completion for readline, as it will be a much
better experience when using phpns in this way. To enable menu completion I use the following commands, 
you could add these to your `bashrc` or `bash_aliases` if you would like this behaviour to be permanent.

```bash
bind 'set show-all-if-ambiguous on'
bind 'TAB:menu-complete'
```
