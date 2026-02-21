use std::fs;
use zed_extension_api::{self as zed, settings::LspSettings, LanguageServerId, Result};

const BLOC_TOOLS_REPO: &str = "felangel/bloc";
const BLOC_TOOLS_RELEASE_TAG_PREFIX: &str = "bloc_tools-v";

struct BlocExtension {
    cached_binary_path: Option<String>,
}

impl BlocExtension {
    fn language_server_binary_path(
        &mut self,
        language_server_id: &LanguageServerId,
        worktree: &zed::Worktree,
    ) -> Result<String> {
        let binary_settings = LspSettings::for_worktree("bloc-language-server", worktree)
            .ok()
            .and_then(|s| s.binary);

        if let Some(path) = binary_settings.as_ref().and_then(|s| s.path.clone()) {
            return Ok(path);
        }

        if let Some(path) = &self.cached_binary_path {
            if fs::metadata(path).map_or(false, |m| m.is_file()) {
                return Ok(path.clone());
            }
        }

        zed::set_language_server_installation_status(
            language_server_id,
            &zed::LanguageServerInstallationStatus::CheckingForUpdate,
        );

        let release = zed::latest_github_release(
            BLOC_TOOLS_REPO,
            zed::GithubReleaseOptions {
                require_assets: true,
                pre_release: true,
            },
        )?;

        // Only consider bloc_tools releases
        if !release.version.starts_with(BLOC_TOOLS_RELEASE_TAG_PREFIX) {
            return Err(format!(
                "Latest release '{}' is not a bloc_tools release",
                release.version
            ));
        }

        let (os, arch) = zed::current_platform();

        let asset_name = format!(
            "bloc_{os}_{arch}",
            os = match os {
                zed::Os::Mac => "macos",
                zed::Os::Linux => "linux",
                zed::Os::Windows => "windows",
            },
            arch = match arch {
                zed::Architecture::Aarch64 => "arm64",
                zed::Architecture::X8664 => "x64",
                zed::Architecture::X86 => "x64",
            },
        );

        let asset = release
            .assets
            .iter()
            .find(|a| a.name == asset_name)
            .ok_or_else(|| {
                format!(
                    "No compatible binary found for this platform (looked for '{}')",
                    asset_name
                )
            })?;

        let version_dir = format!("bloc_tools-{}", release.version);
        let binary_path = format!("{version_dir}/{asset_name}");

        if !fs::metadata(&binary_path).map_or(false, |m| m.is_file()) {
            zed::set_language_server_installation_status(
                language_server_id,
                &zed::LanguageServerInstallationStatus::Downloading,
            );

            fs::create_dir_all(&version_dir).map_err(|e| {
                format!("Failed to create directory '{version_dir}': {e}")
            })?;

            zed::download_file(
                &asset.download_url,
                &binary_path,
                zed::DownloadedFileType::Uncompressed,
            )
            .map_err(|e| format!("Failed to download bloc_tools: {e}"))?;

            zed::make_file_executable(&binary_path)?;

            // Clean up old versions
            if let Ok(entries) = fs::read_dir(".") {
                for entry in entries.flatten() {
                    if let Some(name) = entry.file_name().to_str() {
                        if name.starts_with("bloc_tools-") && name != version_dir {
                            fs::remove_dir_all(entry.path()).ok();
                        }
                    }
                }
            }
        }

        self.cached_binary_path = Some(binary_path.clone());
        Ok(binary_path)
    }
}

impl zed::Extension for BlocExtension {
    fn new() -> Self {
        BlocExtension {
            cached_binary_path: None,
        }
    }

    fn language_server_command(
        &mut self,
        language_server_id: &LanguageServerId,
        worktree: &zed::Worktree,
    ) -> Result<zed::Command> {
        let binary_path = self.language_server_binary_path(language_server_id, worktree)?;

        let args = LspSettings::for_worktree("bloc-language-server", worktree)
            .ok()
            .and_then(|s| s.binary)
            .and_then(|b| b.arguments)
            .unwrap_or_else(|| vec!["language-server".to_string()]);

        Ok(zed::Command {
            command: binary_path,
            args,
            env: Default::default(),
        })
    }
}

zed::register_extension!(BlocExtension);
