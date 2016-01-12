# iTerm 2 Setup
By Jason Yao

## Descripttion
In order to have a consistent "nice" way of terminal access, the following steps need to be performed:

- Download [iTerm 2](https://www.iterm2.com/downloads.html)

- `nano /Applications/iTerm.app/Contents/Info.plist`

- Add to near the end before the `</dict>` tag the following lines of code

```xml
<key>LSUIElement</key>
<true/>
```
