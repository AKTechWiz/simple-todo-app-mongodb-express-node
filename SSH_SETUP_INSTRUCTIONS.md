# 🔐 GitHub SSH Key Setup - Quick Reference

## ✅ Setup Complete!

Your SSH key has been generated and Git is configured to use SSH authentication.

---

## 📋 Your SSH Public Key

```
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGIlcYR0NSsroqnaGHiiTtsHtSeW0vKV1tBFR7j2JrMx github-devops-project
```

**Location:** `C:\Users\HP\.ssh\id_ed25519.pub`

---

## 🔧 Add SSH Key to GitHub (Required Step!)

### Step-by-Step Instructions:

1. **Copy the SSH key above** (the entire line starting with `ssh-ed25519`)

2. **Go to GitHub Settings:**
   - Visit: https://github.com/settings/keys
   - Or: GitHub → Settings → SSH and GPG keys

3. **Click "New SSH key"** (green button)

4. **Fill in the form:**
   - **Title:** `DevOps Project PC` (or any name you prefer)
   - **Key type:** `Authentication Key`
   - **Key:** Paste your SSH public key here

5. **Click "Add SSH key"**

6. **Confirm** with your GitHub password if prompted

---

## ✅ Test Your SSH Connection

After adding the key to GitHub, test it:

```powershell
ssh -T git@github.com
```

**Expected output:**
```
Hi AKTechWiz! You've successfully authenticated, but GitHub does not provide shell access.
```

If you see this message, your SSH key is working! ✅

---

## 📤 Push Your Code to GitHub

Once SSH key is added and tested, push your DevOps project:

```powershell
# Make sure you're in the project directory
cd c:\Users\HP\Desktop\Devops\simple-todo-app-mongodb-express-node

# Add all files
git add .

# Commit with a message
git commit -m "Add DevOps CI/CD pipeline with Jenkins, Docker, K8s, and Monitoring"

# Ensure you're on master branch
git branch -M master

# Push to GitHub
git push -u origin master
```

---

## 🔄 Git Configuration Summary

### Remote URL (SSH):
```
git@github.com:AKTechWiz/simple-todo-app-mongodb-express-node.git
```

### Git User Configuration:
- **Name:** AKTechWiz
- **Email:** your.email@example.com

### To Update Git User (Optional):
```powershell
git config user.name "Your Name"
git config user.email "your.email@example.com"
```

---

## 🚨 Troubleshooting

### Issue 1: "Permission denied (publickey)"

**Solution:**
1. Make sure you added the SSH key to GitHub
2. Test connection: `ssh -T git@github.com`
3. Check if key was added: `ssh-add -l`

### Issue 2: "Host key verification failed"

**Solution:**
```powershell
ssh-keyscan github.com >> $env:USERPROFILE\.ssh\known_hosts
```

### Issue 3: Git still asking for password

**Solution:**
Make sure remote URL uses SSH (not HTTPS):
```powershell
git remote -v
# Should show: git@github.com:... (not https://)

# If it shows https://, change it:
git remote set-url origin git@github.com:AKTechWiz/simple-todo-app-mongodb-express-node.git
```

### Issue 4: SSH agent not running

**Solution:**
```powershell
Start-Service ssh-agent
ssh-add $env:USERPROFILE\.ssh\id_ed25519
```

---

## 📚 Common Git Commands

### Check Repository Status:
```powershell
git status
```

### View Remote URL:
```powershell
git remote -v
```

### Add Files:
```powershell
git add .                    # Add all files
git add filename.txt         # Add specific file
```

### Commit Changes:
```powershell
git commit -m "Your message"
```

### Push to GitHub:
```powershell
git push origin master       # Push to master branch
git push                     # Push to current branch
```

### Pull from GitHub:
```powershell
git pull origin master
```

### View Commit History:
```powershell
git log --oneline
```

---

## 🔒 SSH Key Files Location

### Private Key (Keep Secret!):
```
C:\Users\HP\.ssh\id_ed25519
```
⚠️ **NEVER share this file!**

### Public Key (Safe to Share):
```
C:\Users\HP\.ssh\id_ed25519.pub
```
✅ This is what you add to GitHub

---

## 📝 Next Steps After Push

1. ✅ Add SSH key to GitHub
2. ✅ Test SSH connection
3. ✅ Push code to GitHub
4. ⏭️ Setup GitHub webhook in repository settings
5. ⏭️ Configure Jenkins on AWS EC2
6. ⏭️ Create Jenkins pipeline job
7. ⏭️ Run first build!

---

## 🎯 Quick Commands Summary

```powershell
# Test SSH connection
ssh -T git@github.com

# Check git status
git status

# Add, commit, and push
git add .
git commit -m "Your message"
git push origin master

# View remote
git remote -v

# View your SSH key
Get-Content $env:USERPROFILE\.ssh\id_ed25519.pub
```

---

## 🌟 Important Notes

1. **SSH Key is Permanent:** You only need to add it to GitHub once
2. **Multiple Machines:** You can add multiple SSH keys (one per machine)
3. **Security:** Never commit your private key to a repository
4. **Backup:** Consider backing up your SSH keys to a secure location

---

## 🔗 Useful Links

- **GitHub SSH Keys:** https://github.com/settings/keys
- **GitHub SSH Docs:** https://docs.github.com/en/authentication/connecting-to-github-with-ssh
- **Your Repository:** https://github.com/AKTechWiz/simple-todo-app-mongodb-express-node

---

## ✅ Checklist

- [x] SSH key generated
- [x] Git repository initialized
- [x] Git remote configured with SSH
- [x] Git user configured
- [ ] SSH key added to GitHub (YOU NEED TO DO THIS!)
- [ ] SSH connection tested
- [ ] Code pushed to GitHub

---

**Setup Date:** December 16, 2025  
**SSH Key Type:** ed25519  
**Status:** ✅ Ready to use after adding key to GitHub
