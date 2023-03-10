@description('''
  Pass arguments to use in the deployment script. Default: Empty Object
  Example value:
  {
    SpnName: 'value'
    SpnKey: 'value'
  }
''')
param parArgument object = {
  SpnName: 'value'
  SpnKey: 'value'
}

@description('Delimiter variable is used for the join() method')
var varDelimiter = ' '

var varJoined = !empty(parArgument) ? join(map(items(parArgument), arg => '-${arg.key} ${arg.value}'), varDelimiter) : ''

@description('''
  Example output:
  -SpnName value -SpnKey value
''')
output outArguments string = varJoined
