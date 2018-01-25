
include "./parser";


def testGetFileName: {"file.swift": {}} | getFileName == "file.swift";

def testGetTypeName: {"key.name": "name"} | getTypeName == "name";

def oneFileExample:
    [
    { "file1.swift": {
        "key.substructure": [
            {
                "key.name": "swiftClass",
                "key.kind": "source.lang.swift.decl.class",
                "key.substructure": [
                    {
                        "key.typename": "other_class",
                        "key.kind": "source.lang.swift.decl.var.instance"
                    }
                ]
            },
            {
                "key.name": "other_class",
                "key.kind": "source.lang.swift.decl.class",
                "key.substructure": [
                    {
                        "key.typename": "Int",
                        "key.kind": "source.lang.swift.decl.var.instance"
                    }
                    ]
            }
        ]
    }
    }
    ];

def oneFileExpected: {
        "file1.swift": {
            "other_class": [],
            "swiftClass": [ "other_class" ]
            }
        };

def testParse_shouldFilterTypesInSameFile: (oneFileExample | parse) == oneFileExpected;

def multipleFilesExample:
    [
    { "file1.swift": {
        "key.substructure": [
            {
                "key.name": "swiftClass",
                "key.kind": "source.lang.swift.decl.class",
                "key.substructure": [
                    {
                        "key.typename": "other_class",
                        "key.kind": "source.lang.swift.decl.var.instance"
                    }
                ]
            }
        ]
    }
    },
    { "file2.swift": {
        "key.substructure": [
            {
                "key.name": "other_class",
                "key.kind": "source.lang.swift.decl.class",
                "key.substructure": [ ]
            }
        ]
    }
    }
    ];

def multipleFilesExpected: {
        "file1.swift": {
            "swiftClass": [ "other_class" ]
            },
        "file2.swift": {
            "other_class": []
            }
        };

def extensionsExample:
    [
    { "file1.swift": {
        "key.substructure": [
            {
                "key.name": "swiftClass",
                "key.kind": "source.lang.swift.decl.extension",
                "key.substructure": [
                    {
                        "key.typename": "other_class",
                        "key.kind": "source.lang.swift.decl.var.instance"
                    }
                ]
            }
        ]
    }
    }
    ];

def extensionsExpected: {
        "file1.swift": { }
        };

def testParse_shouldIgnoreExtensions: (extensionsExample | parse ) == extensionsExpected;

def testParse_shouldFilterTypesInDifferentFiles: (multipleFilesExample | parse) == multipleFilesExpected;

{
    testGetFileName: testGetFileName,
    testGetTypeName: testGetTypeName,
    testParse_shouldFilterTypesInSameFile: testParse_shouldFilterTypesInSameFile,
    testParse_shouldFilterTypesInDifferentFiles: testParse_shouldFilterTypesInDifferentFiles,
    testParse_shouldIgnoreExtensions: testParse_shouldIgnoreExtensions
}

