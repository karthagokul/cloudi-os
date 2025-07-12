# Cloudify OS Live-Build Starter

This repository contains a clean, minimal `live-build` starter for **Cloudify OS** using **Xubuntu XFCE** as the base.

## Features
XFCE (Xubuntu) base  
Docker, Kubernetes, AWS CLI preinstalled  
Clean structure ready for GitHub Actions automation

## Usage

### Local Build

```bash
sudo apt-get update
sudo apt-get install live-build

chmod +x build.sh
./build.sh
```

After build, your ISO will be available as `live-image-amd64.hybrid.iso`.

### Cleaning Up

```bash
sudo lb clean --all
```

### Notes

- You can customize packages in `package-lists/cloudify.list.chroot`.
- You can add custom theming or scripts in `hooks` or `includes.chroot`.

---

## License

MIT

https://raw.githubusercontent.com/mvallim/live-custom-ubuntu-from-scratch/refs/heads/master/README.md