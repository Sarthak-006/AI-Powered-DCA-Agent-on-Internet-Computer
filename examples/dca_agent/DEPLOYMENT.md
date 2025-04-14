# Getting the DCA Agent on GitHub 🚀

Hey team! Here's a quick guide on how to get our project up on GitHub without dragging along all those huge model files.

## Before you start

You'll need:
- Git installed (duh)
- GitHub account
- Coffee ☕

## Quick deployment steps

### 1. Create a GitHub repo

Head over to [GitHub](https://github.com/) and make a new repo. Keep it empty (no README or anything).

### 2. Set up Git locally

```bash
# Navigate to our project
cd examples/dca_agent

# Init Git
git init

# Stage everything (our .gitignore will handle excluding the right stuff)
git add .

# Commit!
git commit -m "First commit of our awesome DCA agent"
```

### 3. Connect and push

```bash
# Connect to GitHub
git remote add origin https://github.com/YOUR_USERNAME/YOUR_REPO.git

# Push it real good
git push -u origin main   # or 'master' if you're old school
```

And boom! 💥 You're on GitHub!

## What's not going to GitHub

Our `.gitignore` handles making sure these don't get uploaded:

- model_files directory (way too big)
- node_modules (obviously)
- build artifacts and generated junk
- any model binaries like .onnx, .pth, etc.
- your environment secrets

## Need to share those big model files?

A few options:
- Git LFS if you're fancy
- Just upload them to Google Drive and share a link
- Add a script that downloads them from somewhere on first run

## Deploying to the IC

For actually getting this thing on the Internet Computer:

1. Make sure dfx is set up right
2. Run `dfx deploy --network=ic`
3. Maybe set up GitHub Actions if you want to get all DevOps-y about it

I've had issues with deployment when npm packages aren't exactly right, so double check the package.json if something breaks.

---

Let me know if you run into issues! I'll probably be online most of the day.

-- Dave 