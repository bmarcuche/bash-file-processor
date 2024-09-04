# File Processor

A Bash script designed to automate file processing tasks, including renaming, verifying checksums, and decrypting files using GPG. The script handles files from specified source directories, performs various operations, and moves them to designated target directories.

## Features

- **MD5 Checksum Verification**: Validates file integrity by comparing MD5 checksums before processing.
- **GPG Decryption**: Automatically decrypts files encrypted with GPG if necessary.
- **File Renaming**: Renames files to ensure consistent naming conventions and adds a timestamp for uniqueness.
- **Logging**: Logs all operations and results to a specified log file for monitoring and troubleshooting.
- **Directory Management**: Moves processed files to appropriate target directories based on their type.

## Prerequisites

- **GPG**: The script uses GPG for decryption. Ensure that GPG is installed and properly configured on your system.
- **Bash**: The script is written in Bash and should be executed in a Unix-like environment.

## Usage

1. Clone this repository or download the script to your desired directory.

    ```bash
    git clone https://github.com/your-repo/bash-file-processor.git
    cd bash-file-processor
    ```

2. Make the script executable:

    ```bash
    chmod +x file_processor.sh
    ```

3. Update the variables in the script to match your environment. These include:
   - `SOURCEDIR`: Source directory for files.
   - `BADGE_SOURCEDIR`, `BADGE_TARGETDIR`, `TARGETDIR`, `GPGFAIL`: Other directories for specific purposes.
   - `LOGFILE`: Path to the log file.
   - `<%=@admin_user%>`: Admin user for setting ownership of processed files.

4. Run the script:

    ```bash
    ./file_processor.sh
    ```

## Functions

### 1. `check_md5sum()`

Verifies the integrity of a file by calculating its MD5 checksum at two different intervals. If the checksums match, the file is considered unchanged and ready for further processing.

### 2. `decrypt_gpg()`

Decrypts GPG-encrypted files using a passphrase stored in the `~/.gnupg/.k` file. If decryption fails, the file is moved to a designated failure directory for further analysis.

### 3. `rename_file()`

Renames files by replacing spaces with underscores, appending a timestamp to the filename, and ensuring a consistent naming convention.

## Logging

All script operations are logged to the file specified in the `LOGFILE` variable (`/opt/fileprocessor/bin/parser.log` by default). Logs include details about file renaming, checksum verification, decryption attempts, and file movements.

## Example Output
```bash
Initiate CSV file move from client upload directory - YYYY-MM-DD HH:MM
Renaming "example file.txt" to "example_file-1625251011.txt" OK 
Decrypting example_file-1625251011.gpg 
Removing example_file-1625251011.gpg 
The decrypted file has been saved as example_file-1625251011 
Moved example_file-1625251011 to /processed
```

## License

This script is licensed under the MIT License. See the [LICENSE](LICENSE) file for more details.

## Contribution

Feel free to fork this repository, submit issues, or create pull requests to improve the script.
