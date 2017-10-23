# A bunch of tools / scripts that can be used with the gorice program


## config_ui

A simple dropdown menu that lists all of your gorice configs.

If any of the configs aren't able to be loaded, an x will show up next to the name.

### How to use

Place this somewhere your bar or other program can run this. I place mine in ~/bin/

Create a ~/gorice/output.yaml.template file, this is where the program will load its info from.

You then need to run `gorice dump group_name ~/gorice/output.yaml.template`

You can make the gorice program output all the configs to this template file, ill show you the format it should be in.


```yaml
configs:
    group_name/config_name.yaml:
        background: "#000000"
        foreground: "#FFFFFF"
        colors:
            - "#FFFFFF"
            - "#FFFFFF"
            (etc...)
    
    group_name/config_2.yaml:
        ...
```

This will highly depend on the structure of your config files. However, if you're familiar with how to use my program it uses the same format here. This is my output.yaml.template

```yaml
configs:
    {{range .}}
    {{.Name}}:
        background: "{{.Data.terminal_background}}"
        foreground: "{{.Data.border_active_color}}"
        colors:{{range .Data.terminal_colors}}
            - "{{.}}"{{end}}
    {{end}} 
```


`{{range .}}` iterates over all of the configs you have. From there on its just like using it in any other template file. Be sure to {{end}}  the range at the bottom.


If you need more info on how to use this engine have a look here - https://golang.org/pkg/text/template/
