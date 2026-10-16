local step = import '../drone/step.jsonnet';



{
    new(verify=false):: step.new("Test-Jsonnet", "byterazor/drone-cli:latest")
      .withCommands([
        'export ERROR=0',
        'for f in $(ls tests); do drone jsonnet --stream --format --stdout --source $f >/dev/null; if [ $? == 1 ]; then export ERROR=1; fi; done',
        'if [ $ERROR -eq 1 ]; then exit 1; done'
      ])
}
