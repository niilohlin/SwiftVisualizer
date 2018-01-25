
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

def collect_object(func):
    ([. | func] | reduce .[] as $o ({}; $o + .));

def collect_array(func):
    ([. | func] | reduce .[] as $o ([]; $o + .));

def collect_string(func):
    ([. | func] | reduce .[] as $o (""; $o + "\n" + . ));

def filterInstanceReferences:
    . as $files |
    $files | .[] as $types |
    $files | collect_array(.[] | keys) as $keys |
    def filter:
        reduce .[] as $reference ([]; if ($keys | any(. == $reference))
                then ([$reference] + .)
                else . end
        );
    $files | map_values(map_values(filter))
    ;

def filterTypes: select(.["key.kind"] == "source.lang.swift.decl.protocol"
                    or .["key.kind"] == "source.lang.swift.decl.class"
                    or .["key.kind"] == "source.lang.swift.decl.struct"
                    or .["key.kind"] == "source.lang.swift.decl.enumcase"
                    ) ;

def parse:
    def parseFile:
        getFile as $file |
        $file | getFileName as $fileName |
        def parseTypes:
            $file | getType | filterTypes as $type |
            $type | getTypeName as $typeName |
            { ( $typeName ): $type | getInstanceReferences }
            ;
        collect_object(parseTypes) as $allTypes |
        {($fileName): $allTypes}
        ;
    collect_object(parseFile) as $allFiles |
    $allFiles | filterInstanceReferences
    ;

def type_toDot:
    "\(keys | .[0]) -> test"
    ;
def file_toDot:
    "\( .[] | type_toDot )"
    ;
def toDot:
    collect_string(file_toDot) as $filesDot |
    "digraph G { \($filesDot)}";

[. | parse][0] | toDot




