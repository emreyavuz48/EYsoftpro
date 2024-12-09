import java.util.Scanner;
import  java.io.*;
import java.text.SimpleDateFormat;
import java.util.*;
import java.util.Date;
import java.util.ArrayList;
import java.util.List;
import java.text.SimpleDateFormat;
import java.io.*;
public class Main {
    public static void main(String[] args) {

        FileSystem fileSystem = new FileSystem();
        try {
            fileSystem.loadFromFileSystem("myfiles.txt");
            System.out.println("File system loaded successfully!");
        } catch (Exception e) {
            System.err.println("File system did not load file " + e.getMessage());
        }
        Scanner scanner = new Scanner(System.in);
        while (true) {
            System.out.println("\n--- File System Menu ---");
            System.out.println("1. Add Directory");
            System.out.println("2. Add File");
            System.out.println("3. Remove Directory");
            System.out.println("4. Remove File");
            System.out.println("5. Search by Name");
            System.out.println("6. Search by Extension");
            // System.out.println("7. Display Path");
            System.out.println("8. List Contents");
            System.out.println("9. Display File System");
            System.out.println("0. Exit");

            System.out.print("Enter your choice: ");
            int choice = scanner.nextInt();
            scanner.nextLine(); // Consume newline
            try {
                switch (choice) {
                    case 1 -> addDirectory(fileSystem, scanner);
                    case 2 -> addFile(fileSystem, scanner);
                    case 3 -> removeDirectory(fileSystem, scanner);
                    case 4 -> removeFile(fileSystem, scanner);
                    case 5 -> searchByName(fileSystem, scanner);
                    case 6 -> searchByExtension(fileSystem, scanner);
                    //case 7 -> displayPath(fileSystem, scanner);
                    case 8 -> listContents(fileSystem, scanner);
                    case 9 -> fileSystem.displayFileSystem();
                    case 0 -> {
                        System.out.println("Exiting...");
                        return;
                    }
                    default -> System.out.println("Invalid choice. Please try again.");
                }
            } catch (Exception e) {
                System.err.println("Error: " + e.getMessage());
            }
        }
    }

    private static void addDirectory(FileSystem fileSystem, Scanner scanner) {
        System.out.print("Enter parent directory path: ");
        String path = scanner.nextLine();
        System.out.print("Enter directory name: ");
        String name = scanner.nextLine();
        System.out.print("Enter access level (USER/SYSTEM): ");
        String accessLevel = scanner.nextLine();

        try {
            fileSystem.addDirectory(path, name, accessLevel);
            System.out.println("Directory added successfully.");
        } catch (Exception e) {
            System.err.println("Error: " + e.getMessage());
        }
    }

    private static void addFile(FileSystem fileSystem, Scanner scanner) {
        System.out.print("Enter parent directory path: ");
        String path = scanner.nextLine();
        System.out.print("Enter file name: ");
        String name = scanner.nextLine();
        System.out.print("Enter file extension: ");
        String extension = scanner.nextLine();
        System.out.print("Enter file size (in bytes): ");
        int size = scanner.nextInt();
        scanner.nextLine(); // Consume newline
        System.out.print("Enter access level (USER/SYSTEM): ");
        String accessLevel = scanner.nextLine();
        Date lastModified = new Date();

        try {
            fileSystem.addFile(path, name, extension, size, accessLevel, lastModified);
            System.out.println("File added successfully.");
        } catch (Exception e) {
            System.err.println("Error: " + e.getMessage());
        }
    }

    private static void removeDirectory(FileSystem fileSystem, Scanner scanner) {
        System.out.print("Enter parent directory path: ");
        String path = scanner.nextLine();
        System.out.print("Enter directory name: ");
        String name = scanner.nextLine();

        try {
            fileSystem.removeDirectory(path, name);
            System.out.println("Directory removed successfully.");
        } catch (Exception e) {
            System.err.println("Error: " + e.getMessage());
        }
    }

    private static void removeFile(FileSystem fileSystem, Scanner scanner) {
        System.out.print("Enter parent directory path: ");
        String path = scanner.nextLine();
        System.out.print("Enter file name: ");
        String name = scanner.nextLine();

        try {
            fileSystem.removeFile(path, name);
            System.out.println("File removed successfully.");
        } catch (Exception e) {
            System.err.println("Error: " + e.getMessage());
        }
    }

    private static void searchByName(FileSystem fileSystem, Scanner scanner) {
        System.out.print("Enter name to search: ");
        String name = scanner.nextLine();

        List<TreeNode> results = fileSystem.searchByName(name);
        if (results.isEmpty()) {
            System.out.println("No items found.");
        } else {
            System.out.println("Found items:");
            for (TreeNode path : results) {
                System.out.println(path);
            }
        }
    }

    private static void searchByExtension(FileSystem fileSystem, Scanner scanner) {
        System.out.print("Enter file extension to search: ");
        String extension = scanner.nextLine();

        List<FileNode> results = fileSystem.searchByExtension(extension);
        if (results.isEmpty()) {
            System.out.println("No items found.");
        } else {
            System.out.println("Found files:");
            for (FileNode path : results) {
                System.out.println(path);
            }
        }
    }

    private static void listContents(FileSystem fileSystem, Scanner scanner) {
        System.out.print("Enter directory path: ");
        String path = scanner.nextLine();

        try {
            fileSystem.listContents(path);
        } catch (Exception e) {
            System.err.println("Error: " + e.getMessage());
        }
    }
}
   /* private static void displayPath(FileSystem fileSystem, Scanner scanner) {
        System.out.print("Enter name of file or directory: ");
         name = scanner.nextLine();

        try {
            String path = fileSystem.displayPath(name);
            System.out.println("Path: " + path);
        } catch (Exception e) {
            System.err.println("Error: " + e.getMessage());
        }
    }
*/

public abstract class TreeNode {
    protected String name;
    protected Date lastModified;
    protected int size;
    protected String accessLevel; // "USER" or "SYSTEM"
    protected DirectoryNode parent; // Parent reference for upward traversal

    public TreeNode(String name, Date lastModified, int size, String accessLevel) {
        this.name = name;
        this.lastModified = lastModified;
        this.size = size;
        this.accessLevel = accessLevel;
    }

    // Abstract methods to be implemented by FileNode and DirectoryNode
    public abstract void printDetails();
    public abstract String getFullPath();

    // Common methods
    public String getName() {
        return name;
    }

    public Date getLastModified() {
        return lastModified;
    }

    public int getSize() {
        return size;
    }

    public String getAccessLevel() {
        return accessLevel;
    }

    public void setParent(DirectoryNode parent) {
        this.parent = parent;
    }

    public DirectoryNode getParent() {
        return parent;
    }
}

public class FileNode extends TreeNode{
    private String extension; // File extension like "txt", "pdf", etc.

    public FileNode(String name, String extension, Date lastModified, int size, String accessLevel) {
        super(name, lastModified, size, accessLevel);
        this.extension = extension;
    }

    public String getExtension() {
        return extension;
    }
    @Override
    public void printDetails() {
        System.out.println("File: " + name + "." + extension + " | " + size + " bytes | Last Modified: "
                + lastModified + " | Access Level: " + accessLevel);
    }
    @Override
    public String getFullPath() {
        StringBuilder path = new StringBuilder(name + "." + extension);
        TreeNode current = this;
        while (current.getParent() != null) {
            current = current.getParent();
            path.insert(0, current.getName() + "/");
        }
        return path.toString();
    }
}

public class DirectoryNode extends TreeNode {
    private List<TreeNode> children;

    public DirectoryNode(String name, Date lastModified, String accessLevel) {
        super(name, lastModified, 0, accessLevel); // Size will be calculated dynamically
        this.children = new ArrayList<>();
    }
    public void addChild(TreeNode child) {
        if ("USER".equals(this.accessLevel)) {
           this.children.add(child);
            child.setParent(this);
            recalculateProperties();
        } else {
            System.out.println("Cannot add child. Directory access level is SYSTEM.");
        }
    }
    public void removeChild(TreeNode child) {
        if (this.children.contains(child) && "USER".equals(this.accessLevel)) {
            this.children.remove(child);
            recalculateProperties();
        } else {
            System.out.println("Cannot remove child. Either it's not found, or directory access level is SYSTEM.");
        }
    }

    private void recalculateProperties() {
        int totalSize = 0;
        Date latestModified = null;
        boolean allSystemAccess = true;

        for (TreeNode child : children) {
            totalSize += child.getSize();
            if (latestModified == null || child.getLastModified().after(latestModified)) {
                latestModified = child.getLastModified();
            }
            if (!"SYSTEM".equals(child.getAccessLevel())) {
                allSystemAccess = false;
            }
        }

        this.size = totalSize;
        this.lastModified = latestModified;
        this.accessLevel = allSystemAccess ? "SYSTEM" : "USER";
    }

    public int getSize() {
        return children.stream().mapToInt(TreeNode::getSize).sum();
    }
    @Override
    public void printDetails() {
        System.out.println("Directory: " + name + " | " + size + " bytes | Last Modified: "
                + lastModified + " | Access Level: " + accessLevel);
        for (TreeNode child : children) {
            child.printDetails();
        }
    }
    @Override
    public String getFullPath() {
        StringBuilder path = new StringBuilder(name);
        TreeNode current = this;
        while (current.getParent() != null) {
            current = current.getParent();
            path.insert(0, current.getName() + "/");
        }
        return path.toString();
    }


    public List<TreeNode> getChildren() {
        return children;
    }
}

public class FileSystem {
    private DirectoryNode root;

    public FileSystem() {
        root = new DirectoryNode("root", new Date(),"USER" );
    }
public DirectoryNode getRoot(){
        return root;
    }

    public void loadFromFileSystem(String filePath) throws IOException {
        try (BufferedReader reader = new BufferedReader(new FileReader(filePath))) {
            String line;
            DirectoryNode currentDir = root;

            while ((line = reader.readLine()) != null) {
                if (line.startsWith("\\")) { // Directory
                    String dirName = line.substring(1).trim();
                    currentDir = new DirectoryNode(dirName, new Date(), "USER");
                    root.addChild(currentDir);
                } else { // File
                    String[] parts = line.split("##");
                    String fileName = parts[0].trim();
                    Date lastModified = new SimpleDateFormat("dd.MM.yyyy").parse(parts[1].trim());
                    int size = Integer.parseInt(parts[2].trim());
                    String accessLevel = parts[3].trim();
                    FileNode file = new FileNode(fileName, fileName.substring(fileName.lastIndexOf(".") + 1),
                            lastModified, size, accessLevel);
                    currentDir.addChild(file);
                }
            }
        } catch (Exception e) {
            throw new IOException("Parsing file system data unsuccesfull: " + e.getMessage());
        }
    }


    public void addDirectory(String path, String name, String accessLevel) throws FileSystemException {
        DirectoryNode parent = findDirectory(path);
        if (parent == null) {
            throw new InvalidPathException("Path not found: " + path);
        }
        if (!"USER".equals(parent.getAccessLevel())) {
            throw new AccessViolationException("Cannot add directory. Parent directory access level is SYSTEM.");
        }

        DirectoryNode newDir = new DirectoryNode(name, new Date(),accessLevel);
        parent.addChild(newDir);
    }

    public void addFile(String path, String name, String extension, int size, String accessLevel, Date lastModified) throws FileSystemException {
        DirectoryNode parent = findDirectory(path);
        if (parent == null) {
            throw new InvalidPathException("Path not found: " + path);
        }
        if (!"USER".equals(parent.getAccessLevel())) {
            throw new AccessViolationException("Cannot add file. Parent directory access level is SYSTEM.");
        }

        FileNode file = new FileNode(name, extension,lastModified, size, accessLevel);
        parent.addChild(file);
    }
    public void removeDirectory(String path, String name) throws FileSystemException {
        // Find the parent directory
        DirectoryNode parent = findDirectory(path);
        if (parent == null) {
            throw new InvalidPathException("Invalid path: " + path);
        }

        // Locate the directory to remove
        TreeNode target = null;
        for (TreeNode child : parent.getChildren()) {
            if (child instanceof DirectoryNode && child.getName().equals(name)) {
                target = child;
                break;
            }
        }

        if (target == null) {
            throw new InvalidPathException("Directory not found: " + name + " in path " + path);
        }

        if (!"USER".equals(target.getAccessLevel())) {
            throw new AccessViolationException("Cannot delete directory. Directory access level is SYSTEM: " + name);
        }

        // Check if the directory contains any SYSTEM-level files or directories
        DirectoryNode directoryToRemove = (DirectoryNode) target;
        if (containsSystemLevelContent(directoryToRemove)) {
            throw new AccessViolationException("Cannot delete directory: " + name + ". It contains SYSTEM-level files or subdirectories.");
        }

        // Remove the directory from the parent
        parent.removeChild(target);
    }

    public void removeFile(String path, String name) throws FileSystemException {
        DirectoryNode parent = findDirectory(path);
        if (parent == null) {
            throw new InvalidPathException("Invalid path: " + path);
        }

        TreeNode target = null;
        for (TreeNode child : parent.getChildren()) {
            if (child instanceof FileNode && child.getName().equals(name)) {
                target = child;
                break;
            }
        }

        if (target == null) {
            throw new InvalidPathException("File not found: " + name + " in path " + path);
        }

        if (!"USER".equals(target.getAccessLevel())) {
            throw new AccessViolationException("Cannot delete file. File access level is SYSTEM: " + name);
        }

        parent.removeChild(target);
    }

    private boolean containsSystemLevelContent(DirectoryNode directory) {
        for (TreeNode child : directory.getChildren()) {
            if ("SYSTEM".equals(child.getAccessLevel())) {
                return true;
            }
            if (child instanceof DirectoryNode) {
                if (containsSystemLevelContent((DirectoryNode) child)) {
                    return true;
                }
            }
        }
        return false;
    }
    private DirectoryNode findDirectory(String path) {
        if (path.equals("/")) return root;

        String[] parts = path.split("/");
        DirectoryNode current = root;

        for (String part : parts) {
            if (part.isEmpty()) continue;
            boolean found = false;

            for (TreeNode child : current.getChildren()) {
                if (child instanceof DirectoryNode && child.getName().equals(part)) {
                    current = (DirectoryNode) child;
                    found = true;
                    break;
                }
            }
            if (!found) return null;
        }
        return current;
    }

    public List<TreeNode> searchByName(String name) {
        List<TreeNode> result = new ArrayList<>();
        searchByNameRecursive(root, name, result);
        return result;
    }

    private void searchByNameRecursive(TreeNode current, String name, List<TreeNode> result) {
        if (current.getName().equalsIgnoreCase(name)) {
            result.add(current);
        }

        if (current instanceof DirectoryNode) {
            for (TreeNode child : ((DirectoryNode) current).getChildren()) {
                searchByNameRecursive(child, name, result);
            }
        }
    }

    public List<FileNode> searchByExtension(String extension) {
        List<FileNode> result = new ArrayList<>();
        searchByExtensionRecursive(root, extension, result);
        return result;
    }

    private void searchByExtensionRecursive(TreeNode current, String extension, List<FileNode> result) {
        if (current instanceof FileNode) {
            FileNode file = (FileNode) current;
            if (file.getExtension().equalsIgnoreCase(extension)) {
                result.add(file);
            }
        }

        if (current instanceof DirectoryNode) {
            for (TreeNode child : ((DirectoryNode) current).getChildren()) {
                searchByExtensionRecursive(child, extension, result);
            }
        }
    }

    public String getPath(TreeNode node) {
        StringBuilder path = new StringBuilder(node.getName());
        while (node.getParent() != null) {
            node = node.getParent();
            path.insert(0, node.getName() + "/");
        }
        return path.toString();
    }

    public void listContents(String path) throws FileSystemException {
        DirectoryNode directory = findDirectory(path);
        if (directory == null) {
            throw new InvalidPathException("Directory not found: " + path);
        }
        if (!"USER".equals(directory.getAccessLevel())) {
            throw new AccessViolationException("Access denied to directory: " + path);
        }

        for (TreeNode child : directory.getChildren()) {
           child.printDetails();
        }
    }
    private String findPath(TreeNode current, String itemName, String currentPath) {
        // Build the current path
        String fullPath = currentPath + "/" + current.getName();

        // Check if the current node matches the itemName
        if (current.getName().equalsIgnoreCase(itemName)) {
            return fullPath;
        }
        return null;
    }
        public void displayPath (String itemName){
            try {
                String path = findPath(root, itemName, "");
                if (path == null) {
                    throw new Exception("Item not found: " + itemName);
                }
                System.out.println("Path: " + path);
            } catch (Exception e) {
                System.err.println("Error displaying path: " + e.getMessage());
            }
        }


        public void displayFileSystem () {
            displayFileSystemRecursive(root, 0);
        }
        private void displayFileSystemRecursive (TreeNode current,int depth){
            System.out.print("  ".repeat(depth));
            current.printDetails();
            if (current instanceof DirectoryNode) {
                for (TreeNode child : ((DirectoryNode) current).getChildren()) {
                    displayFileSystemRecursive(child, depth + 1);
                }
            }
        }

}

public class FileSystemException extends Exception{
    public FileSystemException(String message) {
        super(message);
    }
}

public class InvalidPathException extends FileSystemException{
    public InvalidPathException(String message) {
        super(message);
    }
}

public class AccessViolationException extends FileSystemException {
    public AccessViolationException(String message) {
        super(message);
    }
}




