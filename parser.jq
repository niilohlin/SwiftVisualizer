
def getFile: .[];

def getFileName: keys | .[0];

# @param type
# @returns a list of type name of the file
# getType | getTypeName
def getTypeName: .["key.name"];

def getType: .[] | .["key.substructure"] | .[];

def getInstances: select(.["key.kind"] == "source.lang.swift.decl.var.instance" or .["key.kind"] == "source.lang.swift.decl.let.instance" ) ;

def getInstanceName:
   .["key.typename"] |
   gsub("[\\!\\?\\]\\[]"; "");

# @param type declaration
# @returns a list of vars and let in that type
def getInstanceReferences: [
        .["key.substructure"] | .[] |
        getInstances |
        getInstanceName
    ] |
    unique;

def filterInstanceReferences:
    . as $types |
    $types | keys as $keys |
    def filter:
        reduce .[] as $reference ([]; if ($keys | contains([$reference]))
                then ([$reference] + .)
                else . end
        );
    $types | map_values(filter)
    ;

def parse:
    def parseFile:
        getFile as $file |
        $file | getFileName as $fileName |
        def parseTypes:
            $file | getType as $type |
            $type | getTypeName as $typeName |
            { ( $typeName ): $type | getInstanceReferences }
            ;
        ([. | parseTypes] | reduce .[] as $o ({}; $o + .)) as $allTypes |
        {($fileName): ($allTypes )}
        ;
    parseFile | map_values(filterInstanceReferences)
    ;
#parse



