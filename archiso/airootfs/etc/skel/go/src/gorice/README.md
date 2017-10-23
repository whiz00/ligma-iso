# Gorice

Gorice is a program that lets you add variables to files and load different configs with a simple command.


# Install

First you need to install golang - https://golang.org/doc/install

Then use `go get gitlab.com/sj1k/gorice`

Tada!


# How to use

1. [Set your EDITOR env variable](#set_your_editor_env_variable)
2. [Create a group](#create_a_group)
3. [Create a config](#create_a_config)
    1. [How to use the YAML format.](#the_yaml_format)
4. [Track files](#track_files)
5. [Edit tracked files](#edit_tracked_files)
    1. [Implement your theme variables](#implement_your_theme_variables)
6. [Load your config](#load_your_config)
7. (Optional) [Edit your reload.sh](#reload.sh)
8. (Optional) [Edit the default.yaml](#default.yaml)


## Set your EDITOR env variable

You are required to set this variable so you can edit themes via this program.

Add the following to your ~/.bashrc

```
export EDITOR="your_favorite_editor"
```

This tells my program you want to use your_favorite_editor to edit your themes.


## Create a group

`gorice create group_name`

A group is a folder to store similar configs inside. Each group will have the following:

- A list of files that will be modified by this program, ( your dotfiles )
- A list of theme files (.yaml files)
- A reload.sh script, created when you create the group.
- A default.yaml theme file, created when you create the group.

All of these will be explained in a later step.


## Create a config

`gorice edit group_name/config_name`

This command will bring up your favorite editor so you can edit the config file.

There is no limit to the number of configs you can make.

They all show up in the path ~/.gorice/templates/group_name/

These are .yaml config files. If you are not sure how to use this format, I cover it briefly in the next step.

Using this instead of opening it via your editor lets my program live reload a config when these conditions are met:

- The config you are changing is the one you currently have active.
- You've actually modified the file you're editing.

If the config you edit is malformed and it attempts to reload it, there will be no errors. This is to prevent output to CLI editors. It wont modify any of your files and will not run the reload.sh


### The YAML format

[Here is the wiki page](https://en.wikipedia.org/wiki/YAML)

I will show you a few simple examples you would generally use in my program


```yaml
color:
    background: "#FF0000"                     # A string containing a color
    foreground: "#0000FF"
    
border: 10                                    # An int with the value of 10
colors: ["#FFFFFF", "#000000", "#f0a32b"]    # An array with 3 strings
```

I will cover how to use this example in the template files in a later step.

[An example](/examples/theme.yaml)


## Track files

`gorice track group_name /path/to/dotfile.txt ~/other/path/to/file.txt`

This command is used so this program knows what files it should modify when you load a config.

You can view the list of tracked files via `gorice tracked group_name`

You can remove items from the list via `gorice untrack group_name ~/other/path/to/file.txt`


## Edit tracked files

After you tell my program to track a file a copy of that file will show up in the same directory with the extension .template.

For example, if you tracked a file called `~/.vimrc` a new file will show up called `~/.vimrc.template`

**The .template file is the one you should edit**. My program will load these .template files, modify it based off your theme and then place them in their original place.


### Implement your theme variables

You will need to open one of the .template files and you can start using this format.

I use Go's inbuilt templating engine for this. I have it so you access your variables via

```
{{.Data.variable}}
```


We shall use the YAML example from earlier

```yaml
color:
    background: "#FF0000"                     # A string containing a color
    foreground: "#0000FF"
    
border: 10                                    # An int with the value of 10
colors: ["#FFFFFF", "#000000", "#f0a32b"]    # An array with 3 strings
```


Lets make a pseudo dotfile with these values.


```
background = {{.Data.color_background}}
foreground = {{.Data.color_foreground}}

border_width = {{.Data.border}}

color-0 = {{index .Data.colors 0}}
color-1 = {{index .Data.colors 1}}
color-2 = {{index .Data.colors 3}}
```

Lets break this down.

`{{.Data.color_background}}`   The object has been flattened. This program will flatten the indentation levels down and put _ as the separator.

This is the same for .color_foreground


`{{.Data.border}}` is a direct reference to the value, no flattening needs to happen.

Integers are not handled differently than strings


`{{index .Data.colors 0}}` is referencing an index in the array we created.


An advanced method would be to iterate over the array, Go's template engine supports this.

Lets rebuild the color section

```
{{range $index, $value := .Data.colors}}
color-{{$index}} = {{$value}}
{{end}}
```

After you load your config you will see this in the original file.

```
background = #FF0000    # Strings will not have "" surrounding them. If you want this add them to the .template file.
foreground = #0000FF

border_width = 10
color-0 = #FFFFFF
color-1 = #000000
color-3 = #f0a32b
```

For more information about Go's template engine, [visit here](https://golang.org/pkg/text/template/)

[An example](/examples/polybar.template)


## Load your config

`gorice load group_name/config_name`

Finally the easy step! This is all you need to do to load the config.

This will load all of the .template files that the group is currently tracking and mofify their original files.

After the templating is done, this program will call the reload.sh script. This is explained in the next step.


## Reload.sh

`gorice edit group_name/reload`

This is a file in every group folder that determines what it should run every time you load a group's config.

[An example](/examples/reload.sh)


## Default.yaml

`gorice edit group_name/default`

There are a few features about this default file.

- It will be copied to any new empty config files when you use `gorice edit group_name/config_name`
- It's values will be merged to the theme you load if it's missing values.

**Note:** Anchors will not work across the default / theme files. They are parsed before they get joined.
