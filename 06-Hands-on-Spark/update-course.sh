#!/bin/bash
# Get or update the course materials in your bucket. Run it from a JupyterLab
# terminal on your Dataproc cluster, the first time and every time after.
#
# Files you have changed are never overwritten. If the course also changed one
# of them, the new version is saved next to yours as <name>-updated.<ext>.
set -euo pipefail

SCRIPT_URL=https://raw.githubusercontent.com/soltaniehha/Big-Data-Analytics-for-Business/master/06-Hands-on-Spark/update-course.sh
REPO=${REPO:-https://github.com/soltaniehha/Big-Data-Analytics-for-Business.git}
BUCKET=${BUCKET:-$(/usr/share/google/get_metadata_value attributes/dataproc-bucket)}
DEST=${DEST:-gs://$BUCKET/notebooks/jupyter/Big-Data-Analytics-for-Business}
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT
export GIT_AUTHOR_NAME=student GIT_AUTHOR_EMAIL=student@localhost
export GIT_COMMITTER_NAME=student GIT_COMMITTER_EMAIL=student@localhost

if ! gcloud storage ls "$DEST/.git/HEAD" >/dev/null 2>&1; then
  echo "First run: copying the course into $DEST"
  git clone -q --depth 1 "$REPO" "$WORK"
else
  echo "Updating $DEST"
  gcloud storage rsync -r --no-user-output-enabled "$DEST" "$WORK"
  cd "$WORK"
  git config core.fileMode false       # the bucket does not keep file permissions
  git fetch -q --depth 1 origin HEAD

  # Files you changed or added since the last update
  declare -A mine=()
  while IFS= read -r -d '' f; do mine["$f"]=1; done < <(
    git diff -z --name-only HEAD
    git ls-files -z --others --exclude-standard)

  # Files the course changed since the last update
  updated=0 kept=0
  while IFS= read -r -d '' status && IFS= read -r -d '' f; do
    [ "$status" = D ] && continue        # never delete anything
    if [ -n "${mine[$f]:-}" ]; then
      base=${f%.*} ext=${f##*.}
      [ "$base" = "$f" ] && copy="$f-updated" || copy="$base-updated.$ext"
      git show "FETCH_HEAD:$f" > "$copy"
      echo "  kept your $f; course version saved as $copy"
      kept=$((kept + 1))
    else
      git checkout -q FETCH_HEAD -- "$f"
      updated=$((updated + 1))
    fi
  done < <(git diff -z --name-status --no-renames HEAD FETCH_HEAD)
  git reset -q FETCH_HEAD                 # record this update; your edits stay as edits
  echo "  $updated file(s) updated, $kept kept as yours"
fi

gcloud storage rsync -r --no-user-output-enabled "$WORK" "$DEST"
# Install the short command for next time (it lasts until the cluster is deleted)
if [ -w /usr/local/bin ]; then
  printf '#!/bin/bash\nset -o pipefail\ncurl -fsSL %s | bash\n' "$SCRIPT_URL" > /usr/local/bin/.update-course.new
  chmod +x /usr/local/bin/.update-course.new
  mv -f /usr/local/bin/.update-course.new /usr/local/bin/update-course   # swap in place, safe while it runs
fi
echo "Done. Open the GCS folder in JupyterLab. Next time, just run: update-course"
