# phpns
phpns is a command line interface for the management and indexation of namespaces in PHP
projects. It is written in bash and mainly makes use of grep to index namespaces and the
classes that reside within them. phpns can parse a PHP file and add missing use statements,
provide completions for Fully Qualified Names (FQN's) of namespaces and classes, and more.

## Installation

### With basher
The recommended way to install phpns is with [basher](https://github.com/basherpm/basher), the
packge manager for bash. It will take care of all the troubles of adding completions and adding phpns
to your path, and will make it easy to update to the latest version. You can install phpns with the following
command:

`basher install --ssh hugot/phpns`


### Cloning
phpns does not have any dependencies except for `sed`, `grep` and a couple of other tools that
should be readily available on most Linux systems. To install phpns with git for usage in a bash shell, go through the
following steps.

1. `cd` into an empty directory you want phpns to be installed into.
2. Clone the repository into the directory: `git clone git@github.com:hugot/phpns.git .`
3. Add the bin directory of the  repository to your path and make it permanent:  
`printf 'export PATH="%s:$PATH"\n' "$(pwd)/bin" >> ~/.bashrc && source ~/.bashrc`
4. Source the completions file and make sure it gets sourced every time you start your shell:  
`printf 'source %s\n' "$(pwd)/completions/phpns.bash" >> ~/.bashrc && source completions/phpns.bash`
5. Test your installation by running `phpns help`

## Usage
```
phpns - Resolve namespaces and fix missing use statements in your PHP scripts.
    
    USAGE:
        phpns COMMAND [ ARGUMENTS ] [ OPTIONS ]
    
    COMMANDS:
        ns, namespace FILE : resolve the namespace of a file.
        i, index : Index all php files in a project directory for usage.
        fu, find-use CLASS_NAME : Find the use statement needed to import the provided class.
        fxu, fix-uses FILE : Find all used classes that have no use statement in the provided file and add use statements for them.
        cns, classes-in-namespace NAMESPACE: List all classes for a certain namespace
        cmp, complete WORD: Complete FQN's for namespaces and classes that match WORD.
        fp, filepath FQN: print the filepath of a class by the name of FQN.

    TO BE IMPLEMENTED:
        rmuu, remove-unneeded-uses FILE: Remove all use statements for classes that are not being used.

    OPTIONS FOR ALL COMMANDS:
        -s --silent: Don't print info.
    
    UNIQUE OPTIONS PER COMMAND:
        namespace: -
        index:
            -d, --diff: Show differences between the filed in the index and the project directory.
            -N, --new: Only index new files
        find-use:
            -j, --json: Provide possible use FQN's as a json array.
            -p, --prefer-own: If there are matches inside the "src" dir, only use those.
            -a, --auto-pick: Use first encountered match, don't provide a choice.
            -b. --bare: Print FQN's without any additives.
        fix-uses:
            -j, --json: Provide possible use FQN's per class as a json object with the class names as keys.
            -p, --prefer-own: If there are matches inside the "src" dir, only use those.
            -a, --auto-pick: Use first encountered match, for every class, don't provide a choice.
            -o, --stdout: Print to stdout in stead of printing to the selected file.
        complete:
            -e, --expand-classes: If WORD is a class name and no namespaces match, provide the FQN for the class that matches WORD.
            -n, --no-classes: Only complete FQN's for namespaces.
            -c, --complete-classes: If no namespaces match and WORD is not a class name, provide FQN's for all partially matching classes.
        filepath:
            -V, --no-vendor: Exclude vendor dir from search.

```
