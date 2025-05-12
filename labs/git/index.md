# Explore Git

This lab gives more hands-on time with `git`. You will checkout specific commits, tag them, revert, and rollback. 



### Objectives

* Launch VS Code
* From the File menu Select Open Folder
* Select New folder  (upper left)
* Name the folder `labs`
* Click Select Folder to select the labs folder
* In VS Code create new Folder named `git` inside of the labs folder and enter it. 

* Create `Hello.java` containing the following

  ```java
  public class Hello
  {
      public static void main( String argv[] )
      {
          System.out.println( "Hello, World" );
      }
  }
  ```

* Initialize a new repository (git init)

* Add the file to the repository, and commit it

* Change the "Hello, World" program

  ```java
  public class Hello
  {
      public static void main( String argv[] )
      {
          System.out.println( "Hello, " + argv[0] + "!" );
      }
  }
  ```

* Commit your change

* Change the “Hello, World” program to have a default value if a command line argument is not supplied.

  ```java
  public class Hello
  {
      public static void main( String argv[] )
      {
          String name = "World";
          if ( argv.length != 0 )
          {
              name = argv[0];
          }
  
          System.out.println( "Hello, " + name + "!" );
      }
  }
  ```

* Commit the change

Now that we've got a few changes in our repository let's use the `git log` command. 

Using `git log`, we can see the history of our project, including all of our previous commits. This is extremely useful because it allows us to revert our code to previous versions.

View the history

`git log`

As you can see in the output, we have a commit for each of the changes we've made in the repository.

The `git log` command is extremely customizable. 

You have can define what is shown in the output.

Try some of these examples:

```
git log --pretty=oneline
```

```
git log --pretty=oneline --max-count=2
git log --pretty=oneline --since='5 minutes ago'
git log --pretty=oneline --until='5 minutes ago'
git log --pretty=oneline --author=<your name in quotes>
git log --pretty=oneline --all
```



You can also specify the range of commits to show.

```
git log --all --pretty=format:'%h %cd %s (%an)' --since='7 days ago'
```



This command displays pertinent information without overloading the screen

```
git log --pretty=format:'%h %ad | %s%d [%an]' --graph --date=short
```

Let’s look at it in detail:

- `--pretty="..."` defines the format of the output.
- `%h` is the abbreviated hash of the commit
- `%d` are any decorations on that commit (e.g. branch heads or tags)
- `%ad` is the author date
- `%s` is the comment
- `%an` is the author name
- `--graph` informs git to display the commit tree in an ASCII graph layout
- `--date=short` keeps the date format nice and short

Git supports aliases, so you don't have to type the entire string. 

Here are some helpful aliases I use. 

Add them in `~/.git/config` to make life easier.

```
[alias]
  co = checkout
  ci = commit
  st = status
  br = branch
  hist = log --pretty=format:'%h %ad | %s%d [%an]' --graph --date=short
  type = cat-file -t
  dump = cat-file -p
```

Now when you want to see the logs in that specific format you can type `git hist`



## Checkout any previous snapshot

Suppose you want to revert your current directory back to a previous committed version. Going back in history is very easy. The `git checkout` command will copy any snapshot from a previous commit in the repository to the working directory.

## Get the hashes for previous versions

In git, committed versions are uniquely identified with a hash code. This is that strange hierglyphic sequence you saw associated with each commit (something like "commit 56ad4d905ead7db10dde52518b4b161281c0f4ff") in `git log`. Let's take a closer look.

```
git log
```

Examine the log output and find the hash for the FIRST COMMIT (the most bottom). Use that hash code (the first 7 characters are enough) in the command below. By default, git log lists the commits in reverse chronological order (look at the timestamps!). Once you find the hash for the first commit, then check the contents of the `Hello.java` file.

```
git checkout <hash>
```

You will see something similar to: 

```
Note: checking out '9416416'.

You are in 'detached HEAD' state. You can look around, make experimental
changes and commit them, and you can discard any commits you make in this
state without impacting any branches by performing another checkout.

If you want to create a new branch to retain commits you create, you may
do so (now or later) by using -b with the checkout command again. Example:

  git checkout -b new_branch_name

HEAD is now at 9416416... First Commit
```

A “detached HEAD” message in git just means that `HEAD` (the part of git that tracks what your current working directory should match) is pointing directly to a commit rather than a branch. Any changes that are committed in this state are only remembered as long as you don’t switch to a different branch. As soon as you checkout a new branch or tag, the detached commits will be “lost” (because `HEAD` has moved). If you want to save commits done in a detached state, you need to create a branch to remember the commits.

Now confirm the file has been reverted

```
cat Hello.java
```

Return to the latest version 

```
git checkout master
```



## Tag commits with names for future reference

------

You can create tags for each commit in the case that you don't like the default names. Let’s call the current version of the hello program version 1 (v1).

### Tagging version 1

```
git tag v1
```

Now you can refer to the current version of the program as v1.

### Tagging Previous Versions

Let’s tag the version immediately prior to the current version v1-beta. First we need to checkout the previous version. Rather than lookup up the hash, we will use the `^` notation to indicate “the parent commit of v1”.

If the `v1^` notation gives you any trouble, you can also try `v1~1`, which will reference the same version. This notation means “the first ancestor of v1”.

```
git checkout v1^
cat Hello.java
```

You will be in a detached `HEAD` and have the previous version of the file. 

Tag the commit with `v1-beta`

```
git tag v1-beta
```



### Checking out by tag name

Now try going back and forth between the two tagged versions.

```
git checkout v1
git checkout v1-beta
```

To view all tags use the `git tag` command



## Undo Local Changes (before staging)

------

### Checkout main

Make sure you are on the latest commit in `main` before proceeding.

### Change Hello.java

Sometimes you have modified a file in your local working directory and you wish to just revert to what has already been committed. The checkout command will handle that.

Change `Hello.java` to have a bad comment.

#### File: Hello.java

```
public class Hello
{
    public static void main( String argv[] )
    {
        // This is a bad comment.  We want to revert it.
        String name = "World";
        if ( argv.length != 0 )
        {
            name = argv[0];
        }

        System.out.println( "Hello, " + name + "!" );
    }
}
```

#### Check the Status

First, check the status of the working directory, using `git status`

We see that the `Hello.java` file has been modified, but the changes haven't been staged yet.

### Revert the changes in the working directory

Use the `checkout` command to checkout the repository’s version of the `Hello.java` file.

```
git checkout Hello.java
git status
cat Hello.java
```

The status command shows us that there are no outstanding changes in the working directory. And the “bad comment” is no longer part of the file contents since we "checked out" the file to its previous version.

## Undo Staged Changes (before committing)

------

We just undid unstaged changes; now let's try undoing staged changes.

### Change the file and stage the change

Modify the `Hello.java` file to have a bad comment

### File: Hello.java

```
public class Hello
{
    public static void main( String argv[] )
    {
        // This is an unwanted but staged comment
        String name = "World";
        if ( argv.length != 0 )
        {
            name = argv[0];
        }

        System.out.println( "Hello, " + name + "!" );
    }
}
```

And then go ahead and stage it.

### Check the Status

Check the status of your unwanted change.

The status output shows that the change has been staged and is ready to be committed.

### Reset the Staging Area

Fortunately the status output tells us exactly what we need to do to unstage the change.

```
git reset HEAD Hello.java
```

## Output:

```
$ git reset HEAD Hello.java
Unstaged changes after reset:
M    Hello.java
```

The `git reset` command resets the staging area to be whatever is in `HEAD`. `HEAD` points out the last commit in the current checkout branch. This clears the staging area of the change we just staged.

The `git reset` command (by default) doesn’t change the working directory. The working directory still has the unwanted comment in it. After `git reset` we can use the `git checkout` command of the previous section to remove the unwanted change from the working directory entirely.

### Checkout the Committed Version

```
git checkout Hello.java
git status
```

And our working directory is clean once again.

## Goal: Undo Committed Changes

------

### Undoing Commits

Sometimes you realize that a change you have already committed was not correct and you wish to undo that commit. There are several ways of handling that issue, and the way we are going to use in this lab is always safe.

Essentially we will undo the commit by creating a new commit that reverses the unwanted changes.

### Change the file and commit it.

Change the `Hello.java` file to the following.

#### File: Hello.java

```
public class Hello
{
    public static void main( String argv[] )
    {
        // This is an unwanted but staged comment
        String name = "World";
        if ( argv.length != 0 )
        {
            name = argv[0];
        }

        System.out.println( "Hello, " + name + "!" );
    }
}
```

Add and commit the file with the message:

```
"Oops, we didn't want this commit"
```

### Create a Reverting Commit

To undo a committed change, we need to generate a commit that removes the changes introduced by our unwanted commit.

```
git revert HEAD
```

This will pop you into the editor. You can edit the default commit message or leave it as is. Save and close the file. You should see …

```
$ git revert HEAD --no-edit
[main a10293f] Revert "Oops, we didn't want this commit"
 1 file changed, 1 insertion(+), 1 deletion(-)
```

Since we were undoing the very last commit we made, we were able to use `HEAD` as the argument to revert. We can revert any arbitrary commit earlier in history by simply specifying its hash value.

**Note\***: The `--no-edit` in the output is optional if you want to avoid opening the editor

### Check the log

Checking the log shows both the unwanted and the reverting commits in our repository.

```
git hist
```

This technique will work with any commit (although you may have to resolve conflicts). It is safe to use even on branches that are publicly shared on remote repositories.

## Remove Commits from a Branch

------

The `git revert` command of the previous section is a powerful command that lets us undo the effects of any commit in the repository. However, both the original commit and the “undoing” commit are visible in the branch history (using the `git log` command).

Often we make a commit and immediately realize that it was a mistake. It would be nice to have a “take back” command that would allow us to pretend that the incorrect commit never happened. The “take back” command would even prevent the bad commit from showing up the `git log` history. It would be as if the bad commit never happened.

### The `git reset` command

We’ve already seen the `git reset` command and have used it to set the staging area to be consistent with a given commit (we used the HEAD commit in the previous section).

When given a commit reference (i.e. a hash, branch or tag name), the 'git reset' command will …

1. Rewrite the current branch to point to the specified commit
2. Optionally reset the staging area to match the specified commit
3. Optionally reset the working directory to match the specified commit

### Check Our History

Let’s do a quick check of our commit history.

### Execute:

```
git hist
```

We see that we have an “Oops” commit and a “Revert Oops” commit as the last two commits made in this branch. Let’s remove them using reset.

### First, Mark this Branch

But before we remove the commits, let’s mark the latest commit with a tag so we can find it again.

Tag the latest commit `oops`

### Reset to Before Oops

Looking at the log history (above), we see that the commit tagged ‘v1’ is the commit right before the bad commit. Let’s reset the branch to that point. Since that branch is tagged, we can use the tag name in the reset command (if it wasn’t tagged, we could just use the hash value).

```
git reset --hard v1
git hist
```

### Output:

```
$ git reset --hard v1
HEAD is now at 1f7ec5e Added a comment
```

Our `main` branch now points to the v1 commit and the Oops commit and the Revert Oops commit are no longer in the branch. The `--hard` parameter indicates that the working directory should be updated to be consistent with the new branch head.

### Nothing is Ever Lost

But what happened to the bad commits? It turns out that the commits are still in the repository. In fact, we can still reference them. Remember that at the beginning of this lab we tagged the reverting commit with the tag “oops”. Let’s look at all the commits.

### Execute:

```
git hist --all
```

In our output we see that the bad commits haven’t disappeared. They are still in the repository. It’s just that they are no longer listed in the main branch. If we hadn’t tagged them, they would still be in the repository, but there would be no way to reference them other than using their hash names. Commits that are unreferenced remain in the repository until the system runs the garbage collection software.

### Dangers of Reset

Resets on local branches are generally safe. Any “accidents” can usually be recovered from by just resetting again with the desired commit.

However, if the branch is shared on remote repositories, resetting can confuse other users sharing the branch.

## Remove the oops tag

------

### Removing tag oops

The oops tag has served its purpose. Let’s remove it and allow the commits it referenced to be garbage collected.

### Execute:

```
git tag -d oops
git hist --all
```

The oops tag is no longer listed in the repository.



