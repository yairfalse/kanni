use rustler::NifResult;
use serde::Serialize;
use std::path::Path;

#[derive(Serialize)]
struct RepoEntry {
    path: String,
    name: String,
}

/// Walk a directory tree up to `max_depth` looking for `.git` directories.
/// Returns a JSON array of `{path, name}` objects.
#[rustler::nif(schedule = "DirtyCpu")]
pub fn workspace_scan(root: String, max_depth: usize) -> NifResult<String> {
    let root_path = Path::new(&root);
    let mut repos = Vec::new();

    if !root_path.is_dir() {
        return serde_json::to_string(&repos).map_err(|e| {
            rustler::Error::Term(Box::new(format!("json: {}", e)))
        });
    }

    let walker = walkdir::WalkDir::new(&root)
        .max_depth(max_depth + 1) // +1 because we look for .git inside dirs
        .follow_links(false)
        .into_iter()
        .filter_entry(|e| {
            let name = e.file_name().to_string_lossy();
            // Skip hidden dirs (except .git which we're looking for)
            // Skip node_modules, target, _build etc.
            if e.depth() > 0 && name.starts_with('.') && name != ".git" {
                return false;
            }
            if name == "node_modules" || name == "target" || name == "_build" || name == "deps" {
                return false;
            }
            true
        });

    for entry in walker {
        let entry = match entry {
            Ok(e) => e,
            Err(_) => continue,
        };

        if entry.file_name() == ".git" && entry.file_type().is_dir() {
            if let Some(parent) = entry.path().parent() {
                let repo_path = parent.to_string_lossy().to_string();
                let name = parent
                    .file_name()
                    .map(|n| n.to_string_lossy().to_string())
                    .unwrap_or_else(|| repo_path.clone());

                repos.push(RepoEntry {
                    path: repo_path,
                    name,
                });
            }
        }
    }

    repos.sort_by(|a, b| a.name.cmp(&b.name));

    serde_json::to_string(&repos).map_err(|e| {
        rustler::Error::Term(Box::new(format!("json: {}", e)))
    })
}
