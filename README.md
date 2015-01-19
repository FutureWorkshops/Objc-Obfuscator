
The tool is made of two components:

- One ruby gem that pre-process ObjC source files and encrypts constant string marked as obfuscated by the developer.
- An ObjC library that assist the developer in decrypting those encrypted strings.


### How it works

In order to tag a constant string as obfuscated, the developer simply specify the compiler directive `__obfuscated` next to the string definition like this:

```obj-c
__obfuscated NSString * const myPrivateKey = @"234ba9c824cd578ef924a5f0";
```

and then runs the command line tool provided by the gem:

```bash
$ objc-obfuscator obfuscate myEncryptionKey my_file.m 
```

At this point, the plain-text key on the source file will be replaced by the encrypted counterpart:

```obj-c
NSString * const myPrivateKey = @"ZQdnkwPtba2asdCu12nHZQ==-Jjh28cbD1YsyAd2X+jLZLg==-MTM5MDgyMjIzNg==";
```

Since the string is now stored in an encrypted format, it has to be decrypted everytime it's used. The ObjC library provides an extension to NSString that allows for easy decoding at runtime:

```obj-c
NSString *unencryptedKey = [myPrivateKey unobfuscatedString];
```

The only extra step required at this point is to include and configure the ObjC library with the right key so the `unobfuscatedString` method knows how to decrypt the string. On the app delegate make sure to add:

```obj-c
[[FWTObfuscator defaultObfuscator] setEncryptionKey:@"myEncryptionKey"];
```

### Hiding the encryption key

Some may notice that the problem we started with is not yet solved: a hacker could search for the encryption key and use that to decrypt the encrypted strings.
Unfortunately there's no way of completely secure this key because it needs to be embedded in the final binary as long as we don't want to depend on an external server connection (and deal with all the network issues connected to this).

Our solution to this problem is to use a combination of well known strings, without directly specify them in code. By well known strings I mean strings that are specific of Cocoa-Touch and always available inside the app's binary. For example, a good key could be: 

```obj-c
NSString *myKey = NSString stringWithFormat:@"%@%@",
                                  NSStringFromClass([NSObject class]), 
                                  NSStringFromClass([NSString class]);
```

The combination is the weak spot, the one thing you need to keep secret and it's where the "obscurity" bit of "security by obscurity" takes place.

### Integration
In order to make this whole process transparent to the developer, the strings have to be encrypted before clang compiles the source files and replaced by the decrypted counterpart just after. In this way we achieve two important results:

- The final binary only contains the obfuscated version of sensitive strings.
- The developer sees and checks into the vcs only unobfuscated strings and it's completely removed from the process of obfuscation.

In order to do that we need to add two shell execution phases to our target: one before and one after the compilation takes place.

The gem takes it a step further, and if you're using [Cocoapods](http://cocoapods.org) in your project, you can integrate the library with one single command:

```bash
$ objc-obfuscator integrate myEncryptionKey myproject.xcodeproj
```

The command adapts to different projects structures thanks to the following options:

```
Usage:
  objc-obfuscator integrate [ENCRYPTION_KEY] [PROJECT_FILE]

Options:
  [--podfile=PODFILE]  # Path to the Podfile. 
  [--target=TARGET]    # Xcode project containing the "compile source" build phase. 
```

This will take care of:

- Adding the gem "objc-obfuscator' to the Podfile.
- Adding the required scripts before and after the build phase of the main target on Xcode.


##Conclusions
As we said at the beginning, while obfuscation doesn't provide any additional security, it helps hiding sensitive information so that it's not trivial to reverse engineer your code. 

The encryption framework provided achieves this by using a strong encryption function and a key that is a combination of strings openly available on all iOS binaries. 

The computational overhead is neglect-able (and can always be improved with the implementation of a cache) while from the developer perspective the integration is almost transparent.

##Further reading

- [iOS applications reverse engineering](http://media.hacking-lab.com/scs3/scs3_pdf/SCS3_2011_Bachmann.pdf)

