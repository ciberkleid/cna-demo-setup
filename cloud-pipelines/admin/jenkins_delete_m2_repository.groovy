def mainDir = new File('/var/lib/jenkins/.m2/repository')
def subDir = new File(mainDir, 'test-dir')
def file = new File(subDir, 'test.txt')
 
subDir.mkdirs()  // Create directories.
file << 'sample'  // Create file and add contents.
 
assert mainDir.exists() && subDir.exists() && file.exists()
 
def result = mainDir.deleteDir()  // Returns true if all goes well, false otherwise.
assert result
assert !mainDir.exists() && !subDir.exists() && !file.exists()
