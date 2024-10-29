### STAY ACTIVE FIREFOX 

#### Description
It's just a firefox extension to stay active throughout your sessions by simulating clicks in the dom

#### Directory structure

```
├── src/
│   ├── js/
│   │   ├── background.js
│   │   └── popup.js
│   ├── css/
│   │   └── styles.css
│   ├── icons/
│   │   ├── icon48.png
│   │   └── icon96.png
│   ├── manifest.json
│   └── popup.html
├── build/          # Generated during build
├── dist/           # Generated during packaging
├── Makefile
└── .gitignore
```


#### USEFUL COMMANDS

###### Verify everything is in place

```sh
make verify
```

###### Build the extension

```sh
make build
```

###### Create distribution package

```sh
make zip
```
