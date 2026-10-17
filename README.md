# Outreach releases

Installers for [Outreach](https://github.com/hormuz-labs/outreach), the Hormuz Labs desktop app for Instagram lead outreach.
Every release here is built by CI from a version tag. This repository holds only the downloads.

```bash
brew install hormuz-labs/tap/outreach     # macOS
```

On Debian or Ubuntu, add the signed apt repository once and apt keeps Outreach up to date:

```bash
curl -fsSL https://apt.guahva.com/outreach.gpg | sudo gpg --batch --yes --dearmor -o /usr/share/keyrings/outreach.gpg &&
echo "deb [signed-by=/usr/share/keyrings/outreach.gpg] https://apt.guahva.com stable main" | sudo tee /etc/apt/sources.list.d/outreach.list &&
sudo apt update && sudo apt install outreach
```

Other Linux: the AppImage on the [latest release](https://github.com/hormuz-labs/outreach-releases/releases/latest).
