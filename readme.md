#Envision OS
Envision OS is a Debian based OS, aimed at efficiency, simplicity, and ease of use.
## Installation
Copy and paste the following text into your terminal:
`curl -fsSL https://raw.githubusercontent.com/universaltechvisions/Envision-OS-updater/refs/heads/main/publickey.asc | sudo gpg --dearmor -o /etc/apt/keyrings envision.gpg`

then

Add the following code to /etc/apt/sources.list:
`
deb [arch=amd64] http://raw.githubusercontent.com/universaltechvisions/Envision-OS-updater/main flexible main
deb-src [arch=amd64] http://raw.githubusercontent.com/universaltechvisions/Envision-OS-updater/main flexible main
`
