function migrate_to_ssh {

    # Check if the Git repository is initialized
    if [ ! -d .git ]; then
      echo "This directory is not a Git repository."
      exit 1
    fi

    # Get the current origin URL
    origin_url=$(git config --get remote.origin.url)

    # Check if the origin URL is empty
    if [ -z "$origin_url" ]; then
      echo "No origin URL found."
      exit 1
    fi

    # Check if the origin URL is using HTTPS
    if [[ $origin_url == https://* ]]; then
      # Extract domain, user, and repo name
      ssh_url=$(echo $origin_url | sed -r 's|https://([^/]*)/([^/]*)/([^/]*)(.git)?|git@\1:\2/\3|')

      # Change the origin URL to SSH
      git remote set-url origin $ssh_url

      echo "Git origin URL has been migrated from HTTPS to SSH."
    else
      echo "Git origin URL is not using HTTPS."
    fi
}

find . -maxdepth 1 -name .git -type d | while read git_dir; do
    ( cd $git_dir/.. && migrate_to_ssh )
done

