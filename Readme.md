# Cloudi OS

Howdy  Cloudi ? **Cloudi OS** is a fast, lightweight, and powerful Debian-based Linux distribution built for **cloud-native and AI developers**. With essential tools preinstalled, a clean XFCE interface, and full automation, Cloudi gives you a productive environment out of the box — whether you're building models, deploying containers, or coding in the cloud.

**DISCLAIMER : Just started, wait for the release iso files :)** 
---

## Features

- Based on the minimal Debian/Ubuntu ISO (low bloat)
- Preinstalled Dev Tools: `Docker`, `Python`, `Pip`, `Jupyter`, `tmux`, `kubectl`, `git`, etc.
- AI-Ready: Optional support for `PyTorch`, `TensorFlow`, `Hugging Face Transformers`, `JupyterLab`
- Cloud-Ready: Preloaded CLI tools for `AWS`, `GCP`, `Azure`, `K3s`, and `Terraform`
- Lightweight XFCE desktop with custom themes and wallpapers
- Fully reproducible builds using Ansible inside Docker
- GitHub Actions integration: ISO automatically published to Releases

---

## Build Locally with Docker

```bash
git clone https://github.com/<your-org>/cloudi-os.git
cd cloudi-os

docker build -t cloudi-builder .

docker run --rm \
  -v $PWD:/workspace \
  cloudi-builder \
  ansible-playbook /workspace/playbook.yml
```

> ISO output: `build/image/cloudi-os.iso`

---

## GitHub CI/CD Support

Each time you push a tag (e.g., `v1.0.0`), GitHub Actions will:

- Build Cloudi OS in Docker
- Publish the ISO to GitHub Releases
- (Optional) Generate checksums or GitHub Pages download links

---

## Use Cases

- Developer machines and cloud IDEs
- AI/ML offline dev environments
- Pre-configured OS for VPS/cloud deployment
- Base image for customized distro spinoffs

---

## Tools You Can Add (Pluggable)

Cloudi is modular. Customize your playbook to include:

- `huggingface`, `scikit-learn`, `Jupyter`, `pandas`
- `minikube`, `k3s`, `helm`, `docker-compose`
- DevOps: `ansible`, `terraform`, `vault`, `packer`
- Editors: `neovim`, `vscode-server`, `micro`
