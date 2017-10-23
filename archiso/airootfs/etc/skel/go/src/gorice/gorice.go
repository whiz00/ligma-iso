package main

import (
	"bytes"
	"encoding/json"
	"flag"
	"fmt"
	"github.com/ghodss/yaml"
	"github.com/lucasb-eyer/go-colorful"
	"io"
	"io/ioutil"
	"math/rand"
	"os"
	"os/exec"
	"reflect"
	"strconv"
	"strings"
	"text/template"
	"time"
)

// ConfigData is used to to load the json data.
type ConfigData struct {
	Files   []string `json:"files"`   // A list of files that the config uses.
	Current string   `json:"current"` // The current config being used.
}

// Arguments is a struct I use to pass into each command.
type Arguments struct {
	Param string   // The second argument passed to the script.
	Files []string // The rest of the arguments passed. This is always a list of files.
	Force bool     // Used to force the loading of a config
}

// Template is data that will be passed to the template function.
type Template struct {
	Data map[string]interface{} // A mapping of key, value pairs for config info.
	Name string                 // The name of the config you're loading.
}

// FillDefaults will compare a second Template struct and fill in any that are missing in the original Template.
func (t *Template) FillDefaults(other Template) {
	for name, value := range other.Data {
		_, ok := t.Data[name]
		if !ok {
			t.Data[name] = value
		}
	}
}

// RGB is just a simple struct that contains RGB information.
type RGB struct {
	R float64
	G float64
	B float64
}

// Command is information and a reference to the commands usable at the command line.
type Command struct {
	Reference   func(Arguments)
	Description string
	Usage       string
}

// confDir is the config directory that stores all of the data.
var confDir = os.ExpandEnv("$HOME/.gorice/")

// EDITOR is the bash variable $EDITOR.
var EDITOR = os.Getenv("EDITOR")

// commands is a mapping of usable command line commands.
var commands = map[string]Command{
	"create": Command{
		Reference:   createGroup,
		Description: "Creates a group to store configs.",
		Usage:       "group_name"},
	"load": Command{
		Reference:   loadConfig,
		Description: "Loads a config.",
		Usage:       "group_name/config_name"},
	"track": Command{
		Reference:   addFiles,
		Description: "Tracks files to be put through the config parser for a group.",
		Usage:       "group_name /path/to/file.txt /path/to/other.whatever"},
	"tracked": Command{
		Reference:   listFiles,
		Description: "Lists the files the program is tracking for a group.",
		Usage:       "group_name"},
	"untrack": Command{
		Reference:   removeFiles,
		Description: "Removes files from the tracked list for a group.",
		Usage:       "group_name /path/to/file.txt /path.to/other.whatever"},
	"edit": Command{
		Reference:   editConfig,
		Description: "Edits a config file.",
		Usage:       "group_name/config_name"},
	"list": Command{
		Reference:   listConfigs,
		Description: "Lists the configs you have for a group.",
		Usage:       "group_name"},
	"reload": Command{
		Reference:   reloadConfig,
		Description: "Reloads the current config for a group.",
		Usage:       "group_name"},
	"delete": Command{
		Reference:   deleteConfig,
		Description: "Removes a config from the group.",
		Usage:       "group_name/config_name",
	},
	"dump": Command{
		Reference:   dumpGroup,
		Description: "Loads every config and dumps the data into a file.",
		Usage:       "group_name /path/to/output.template",
	},
	"check": Command{
		Reference:   checkGroup,
		Description: "Checks all configs in the group, if any cannot be loaded it outputs them.",
		Usage:       "group_name",
	},
}

// funcmap is a simple mapping of functions that will get passed to the template files.
var funcmap = template.FuncMap{
	"rgb":       hex2rgb,
	"sumInts":   sumInts,
	"increment": increment,
	"rgbmax":    hex2rgbMax,
}

// Increment increments a color by a certain amount, can be negative.
func increment(hex string, amount float64) string {
	color, _ := colorful.Hex(hex)
	r, g, b := (color.R*255)+amount, (color.G*255)+amount, (color.B*255)+amount

	// Not exactly sure if I need pointers for this but whatever.
	colorz := []*float64{&r, &g, &b}
	for c := range colorz {
		if c < 0 {
			c = 0
		}
		if c > 255 {
			c = 255
		}
	}
	new := colorful.Color{R: r / 255, G: g / 255, B: b / 255}
	return new.Hex()
}

// sumInts sums some ints. Simple huh?
func sumInts(ints ...int) int {
	var total int
	for i := range ints {
		total += i
	}
	return total
}

// hex2rgb congers a hex string to an RGB structure. Used in the templates.
func hex2rgb(hex string) RGB {
	color, _ := colorful.Hex(hex)
	return RGB{color.R * 255, color.G * 255, color.B * 255}
}

func hex2rgbMax(hex string, max float64) RGB {
	color, _ := colorful.Hex(hex)
	return RGB{color.R * max, color.G * max, color.B * max}
}

// addFiles adds files to the configuration group. Nothing more, nothing less.
func addFiles(arg Arguments) {
	backupFiles(arg.Files)
	data := loadData(arg.Param)
	data.Files = append(data.Files, arg.Files...)
	dumpData(arg.Param, data)
}

// removeFiles removes files from the configuration group.
func removeFiles(arg Arguments) {
	data := loadData(arg.Param)
	files := data.Files
	new := []string{}
	for _, name := range files {
		if !isTracking(arg.Files, name) {
			new = append(new, name)
		} else {
			os.Remove(fmt.Sprintf("%s.template", name))
		}
	}
	data.Files = new
	dumpData(arg.Param, data)
}

func isTracking(array []string, data string) bool {
	for _, item := range array {
		if item == data {
			return true
		}
	}
	return false
}

// listFiles lists files tracked in the configuration group.
func listFiles(arg Arguments) {
	data := loadData(arg.Param)
	files := data.Files
	for _, name := range files {
		fmt.Println(name)
	}
}

// dumpData takes a huge data dump in a json file.
// Trust me, it will feel a lot better once it's done.
func dumpData(groupName string, data ConfigData) {
	jsonData, err := json.Marshal(data)
	fullpath := fmt.Sprintf("%stemplates/%s/data.json", confDir, groupName)
	if checkError(err, false) {
		return
	}
	fileWrite(fullpath, string(jsonData))
}

// dumpGroup outputs all information from a group into a template.
func dumpGroup(arg Arguments) {
	groupName := arg.Param
	files := arg.Files

	output := []Template{}
	dir := configList(groupName)
	groupName = strings.TrimPrefix(groupName, ".")
	for _, name := range dir {
		data, err := loadTemplateData(groupName, name+".yaml")
		checkError(err, true)
		output = append(output, data)
	}

	for _, file := range files {
		if !strings.HasSuffix(file, ".template") {
			fmt.Printf("File %s is not a template file, skipping.\n", file)
		}
		err := dumpGroupFile(file, output)
		checkError(err, false)
	}
}

// dumpGroupFile outputs information to a single file.
func dumpGroupFile(templateFile string, info []Template) error {
	var output bytes.Buffer

	originalFile := strings.TrimSuffix(templateFile, ".template")
	data, err := fileRead(templateFile)
	if err != nil {
		return err
	}

	template := template.New(originalFile)
	template.Funcs(funcmap)
	tmp, err := template.Parse(data)
	if err != nil {
		return err
	}
	err = tmp.Execute(&output, info)
	if err != nil {
		return err
	}

	result := output.String()
	os.Remove(originalFile)
	fileWrite(originalFile, result)
	return nil
}

func checkGroup(arg Arguments) {
	groupName := arg.Param
	files := configList(groupName)
	groupName = strings.TrimPrefix(groupName, ".")

	for _, name := range files {
		_, err := loadTemplateData(groupName, name+".yaml")
		if err != nil {
			fmt.Println(name)
		}
	}
}

// listConfigs outputs a list of the configs you have in a certain group.
func listConfigs(arg Arguments) {
	var groupName = string(arg.Param)
	items := configList(groupName)
	for _, item := range items {
		fmt.Println(item)
	}
}

func configList(groupName string) []string {
	showHidden := false
	output := []string{}

	if strings.HasPrefix(groupName, ".") {
		groupName = strings.TrimPrefix(groupName, ".")
		showHidden = true
	}

	folderPath := fmt.Sprintf("%stemplates/%s", confDir, groupName)
	dir, err := ioutil.ReadDir(folderPath)
	checkError(err, true)

	for _, file := range dir {
		name := file.Name()
		if (strings.HasPrefix(name, ".") && !showHidden) || !strings.HasSuffix(name, ".yaml") {
			continue
		}
		output = append(output, strings.TrimSuffix(name, ".yaml"))
	}
	return output
}

// loadData loads one of the config groups data.json file
func loadData(groupName string) ConfigData {
	var config ConfigData
	fullPath := fmt.Sprintf("%stemplates/%s/data.json", confDir, groupName)
	file, err := os.Open(fullPath)

	if !checkError(err, false) {
		data, _ := ioutil.ReadAll(file)
		json.Unmarshal(data, &config)
		return config
	}
	return ConfigData{}
}

// watchConfig watches a config file for changes while you are editing it.
// This is used to reload it on the fly without quitting the editor.
func watchConfig(group string, name string, channel chan bool) {
	fullpath := fmt.Sprintf("%stemplates/%s/%s.yaml", confDir, group, name)
	originalStat, _ := os.Stat(fullpath)

	watch := true
	for watch {
		newStat, _ := os.Stat(fullpath)
		if newStat.ModTime() != originalStat.ModTime() {
			originalStat = newStat
			configName := fmt.Sprintf("%s/%s", group, name)
			loadConfig(Arguments{Param: configName, Files: nil, Force: true})
		}
		select {
		case check := <-channel:
			watch = check
		default:
			watch = true
		}

		time.Sleep(1 * time.Second)
	}
}

// editConfig loads a specified configuration in your favorite editor! If you have $EDITOR set.
func editConfig(arg Arguments) {
	var name string
	var group string
	var fullpath string

	split := strings.Split(arg.Param, "/")
	group = split[0]
	name = split[1]
	jsonData := loadData(group)

	if name == "reload" {
		fullpath = fmt.Sprintf("%stemplates/%s/reload.sh.template", confDir, group)

	} else if name == "current" {
		fullpath = fmt.Sprintf("%stemplates/%s", confDir, jsonData.Current)
		name = strings.Split(jsonData.Current, "/")[1]
		name = strings.TrimSuffix(name, ".yaml")
		arg.Param = fmt.Sprintf("%s/%s", group, name)
	} else {
		fullpath = fmt.Sprintf("%stemplates/%s/%s.yaml", confDir, group, name)
	}

	defaultConfig := fmt.Sprintf("%stemplates/%s/default.yaml", confDir, group)
	_, err := os.Stat(fullpath)
	if err != nil {
		fileCopy(defaultConfig, fullpath)
	}

	watchChan := make(chan bool)
	wait := false
	if jsonData.Current == fmt.Sprintf("%s/%s.yaml", group, name) {
		go watchConfig(group, name, watchChan)
		wait = true
	}

	cmd := exec.Command(EDITOR, fullpath)
	cmd.Stdin = os.Stdin
	cmd.Stdout = os.Stdout
	cmd.Run()

	if wait {
		watchChan <- false
	}

	defaultData, _ := fileRead(defaultConfig)
	currentData, _ := fileRead(fullpath)
	if defaultData == currentData && name != "default" {
		os.Remove(fullpath)
	}
}

// createGroup creates a config group and sets up all of the default files.
func createGroup(arg Arguments) {
	var group string
	var files []string
	var groupPath string

	files = arg.Files
	group = arg.Param
	groupPath = fmt.Sprintf("%stemplates/%s/", confDir, group)

	ok := os.Mkdir(groupPath, 0777)
	if ok == nil {
		fmt.Printf("Creating %s\n", groupPath)
		os.Create(groupPath + "default.yaml")
		os.Create(groupPath + "reload.sh.template")
		os.Chmod(groupPath+"reload.sh", 0755)
		confFile, _ := os.OpenFile(groupPath+"data.json", os.O_RDWR|os.O_CREATE, 0666)

		data := ConfigData{Files: files}
		bytes, err := json.Marshal(data)
		if !checkError(err, false) {
			confFile.Write(bytes)
			backupFiles(files)
		}
	}
}

func deleteConfig(arg Arguments) {
	split := strings.Split(arg.Param, "/")
	group := split[0]
	config := split[1]
	fullpath := fmt.Sprintf("%stemplates/%s/%s.yaml", confDir, group, config)
	err := os.Remove(fullpath)
	checkError(err, true)
}

// reloadConfig reloads the active config.
// You only need to specify the group name for this to work.
func reloadConfig(arg Arguments) {
	name := arg.Param
	data := loadData(name)
	config := strings.Replace(data.Current, ".yaml", "", 1)
	args := Arguments{Param: config, Force: true, Files: nil}
	loadConfig(args)
}

// loadConfig loads a config from a group. If the group/name matches
// the current config it will not load anything.
// If it loads the config it will then attempt to reload the config by
// running its respective reload.sh
func loadConfig(arg Arguments) {
	split := strings.Split(arg.Param, "/")
	group := split[0]
	name := split[1]

	// Check if the config you're loading is the current one.
	// Unless the arg.Force is true execution will stop here.
	configData := loadData(group)
	if configData.Current == fmt.Sprintf("%s/%s.yaml", group, name) && arg.Force == false {
		return
	}

	currentSplit := strings.Split(configData.Current, "/")
	ignoreName := ""
	if len(currentSplit) > 1 {
		ignoreName = currentSplit[1]
	}

	// Find the name, possibly from a random list.
	switch name {
	case "random":
		folderPath := fmt.Sprintf("%stemplates/%s", confDir, group)
		dir, _ := ioutil.ReadDir(folderPath)
		files := shuffleFolder(dir, ignoreName, false)
		name = files[0].Name()
	case ".random":
		folderPath := fmt.Sprintf("%stemplates/%s", confDir, group)
		dir, _ := ioutil.ReadDir(folderPath)
		files := shuffleFolder(dir, ignoreName, true)
		name = files[0].Name()
	default:
		name = name + ".yaml"
	}

	tstruct, err := loadTemplateData(group, name)
	if err != nil {
		return
	}

	// Iterate through the files and load the template data then copy them.
	for _, filepath := range configData.Files {
		templatePath := filepath + ".template"
		err := templateFile(filepath, templatePath, tstruct)
		checkError(err, false)
	}

	// Attempt to reload the config.
	reloadPath := fmt.Sprintf("%stemplates/%s/reload.sh", confDir, group)
	err = templateFile(reloadPath, reloadPath+".template", tstruct)
	if !checkError(err, false) {
		cmd := exec.Command("/bin/sh", reloadPath)
		cmd.Run()
	}

	// Update the 'Current' config.
	jsonData := loadData(group)
	jsonData.Current = fmt.Sprintf("%s/%s", group, name)
	dumpData(group, jsonData)
}

// LoadTemplateData loads the template information for a group / name combo.
func loadTemplateData(group string, name string) (Template, error) {
	var config map[string]interface{}
	var defaultConfig map[string]interface{}

	// Concat the fullpath of the file
	fullpath := fmt.Sprintf("%stemplates/%s/%s", confDir, group, name)
	data, err := fileRead(fullpath)
	if err != nil {
		return Template{}, err
	}

	// Load the YAML data
	err = yaml.Unmarshal([]byte(data), &config)
	if err != nil {
		return Template{}, err
	}
	items := parseYAML(config)
	tstruct := Template{Data: items, Name: fmt.Sprintf("%s/%s", group, name)}

	// Load the default YAML
	defaultPath := fmt.Sprintf("%stemplates/%s/default.yaml", confDir, group)
	defaultData, err := fileRead(defaultPath)

	// If there arent any errors, implement the default data.
	if !checkError(err, false) {
		err = yaml.Unmarshal([]byte(defaultData), &defaultConfig)
		if err != nil {
			return Template{}, err
		}
		ditems := parseYAML(defaultConfig)
		dstruct := Template{Data: ditems}
		tstruct.FillDefaults(dstruct)
	}
	return tstruct, nil
}

// templateFile runs a certain file through the templating engine.
func templateFile(filepath string, templatePath string, templateStruct Template) error {
	var replaced bytes.Buffer
	fileData, err := fileRead(templatePath)
	if err != nil {
		return err
	}
	newTemplate := template.New(filepath)
	newTemplate.Funcs(funcmap)
	tmp, _ := newTemplate.Parse(fileData)

	tmp.Execute(&replaced, templateStruct)
	result := replaced.String()
	os.Remove(filepath)
	err = fileWrite(filepath, result)
	if err != nil {
		return err
	}
	return nil
}

// backupFiles iterates through a slice of files and copies them to a backup.
func backupFiles(files []string) {
	for _, directory := range files {
		newpath := directory + ".template"
		fileCopy(directory, newpath)
	}
}

// A simple filecopy. Not that much to see here.
func fileCopy(source string, dest string) {
	sfile, err := os.Open(source)
	checkError(err, true)
	defer sfile.Close()

	dfile, err := os.Create(dest)
	checkError(err, true)
	defer dfile.Close()

	_, err = io.Copy(dfile, sfile)
	checkError(err, true)

	dfile.Sync()
	checkError(err, true)
}

// checkError is a simple function that checks an error, returns true if
// there was an error and false otherwise.
// The user can specify a fatal param, if this is true the code will stop.
func checkError(err error, fatal bool) bool {
	if err != nil {
		fmt.Println("error:", err)
		if fatal {
			os.Exit(0)
		}
		return true
	}
	return false
}

// shuffleFolder randomly shuffles a list of files in a folder.
// Used when the user loads a random config.
// TODO: Replace this with a random choice rather than random shuffle.
func shuffleFolder(data []os.FileInfo, ignore string, hidden bool) []os.FileInfo {
	var output []os.FileInfo
	for _, file := range data {
		name := file.Name()
		if (strings.HasPrefix(name, ".") && !hidden) || !strings.HasSuffix(name, ".yaml") || name == "default.yaml" || name == ignore {
			continue
		}
		output = append(output, file)
	}
	rand.Seed(time.Now().UnixNano())
	for i := range output {
		j := rand.Intn(i + 1)
		output[i], output[j] = output[j], output[i]
	}
	return output
}

// fileWrite writes to a file. Pretty simple.
func fileWrite(filepath string, data string) error {
	os.Remove(filepath)
	file, err := os.OpenFile(filepath, os.O_WRONLY|os.O_CREATE, 0777)
	if err != nil {
		return err
	}
	defer file.Close()
	_, err = file.Write([]byte(data))
	if err != nil {
		return err
	}
	return nil
}

// fileRead reads a file. Pretty simple.
func fileRead(filepath string) (string, error) {
	file, err := os.Open(filepath)
	if err != nil {
		return "", err
	}
	defer file.Close()
	data, err := ioutil.ReadAll(file)
	if err != nil {
		return "", err
	}
	return string(data), nil
}

// parseYAML parses the YAML configs via the flatten function,
// this will flatten all the elements into simple map[string]interface{}
// structure.
func parseYAML(config map[string]interface{}) map[string]interface{} {
	items := make(map[string]interface{})
	flatten(config, []string{}, items)
	return items
}

// Do the heavy lifting of parsing and flattening of the YAML config files.
func flatten(level map[string]interface{}, path []string, items map[string]interface{}) {
	for name, value := range level {
		path = append(path, name)
		fullpath := strings.Join(path, "_")
		switch value.(type) {
		case string:
			items[fullpath] = value.(string)
		case float64:
			items[fullpath] = strconv.Itoa(int(value.(float64)))
		case map[string]interface{}:
			flatten(value.(map[string]interface{}), path, items)
		case []interface{}:
			values := value.([]interface{})
			items[fullpath] = values
		default:
			fmt.Println(reflect.TypeOf(value))
		}
		path = path[:len(path)-1]
	}
}

// Usage prints out the usage for this program.
func Usage() {
	fmt.Println("Usage: gorice [-f] command [args]")
	fmt.Println()

	flag.PrintDefaults()
	padding := 0
	for command := range commands {
		if len(command) > padding {
			padding = len(command) + 1
		}
	}

	fmt.Println("\nList of commands: ")
	for command := range commands {
		info := commands[command]
		length := len(command)

		strPadding := strings.Repeat(" ", (padding - length))
		fmt.Printf("  info:  %s%s- %s\n  usage: %s %s\n\n", command, strPadding, info.Description, command, info.Usage)
	}
	fmt.Println()
	os.Exit(0)
}

func main() {
	flag.Usage = Usage
	var command string
	var param string
	var files []string
	var force bool

	flag.BoolVar(&force, "f", false, "Forces a config to be reloaded.")
	flag.Parse()

	// Create the folder structure
	os.MkdirAll(fmt.Sprintf("%stemplates/", confDir), 0777)

	args := flag.Args()

	if len(args) < 2 {
		fmt.Println("Not enough arguments.")
		return
	}

	command = args[0]
	param = args[1]
	files = args[2:]

	// Call the function if it exists
	fn, ok := commands[command]
	if ok {
		fn.Reference(Arguments{Param: param, Files: files, Force: force})
	} else {
		fmt.Println("Unknown command", command)
	}
}
