# Command-Line Notes


## Groups

Creating a group:

```{sh}
sudo groupadd <groupname>
```

Add a user to a group:

```{sh}
sudo usermod -aG <username> <groupname>
```

## Make a Common Directory

We will make a directory in which instructors can place materials.  Anyone can read the files in this directory (and execute them if need be), but only instructors can write to this directory.

Assume you have made an `instructors` group.

```{sh}
sudo mkdir /com
sudo chmod -R 775 /com
sudo chown -R :instructors /com
```

## PAT and Credentials (RStudio Server)

Generate a PAT.  In the R console run:

```
usethis::create_github_token()
```

Name the token and copy it to your clipboard.

In the Terminal:

```{sh}
touch .git-credentials
```

Then open this file and add this line:

```
https://<yourgithubusername>:<pasteinyourpat>@github.com
```

Now you can push to your repo, etc.
