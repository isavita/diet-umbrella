defmodule InfoSys.WolframApi.WolframInMemory do
  def fetch_xml(_query) do
    """
    <?xml version='1.0' encoding='UTF-8'?>
    <queryresult success='true'
        error='false'
        numpods='4'
        datatypes=''
        timedout=''
        timedoutpods=''
        timing='0.6910000000000001'
        parsetiming='0.067'
        parsetimedout='false'
        recalculate=''
        id='MSPa1018313a9dcg84c94249a00001619e4bg4g4c38fa'
        host='http://www5b.wolframalpha.com'
        server='53'
        related='http://www5b.wolframalpha.com/api/v2/relatedQueries.jsp?id=MSPa1018413a9dcg84c94249a000068i48cb7e9i16be46807070643161599741'
        version='2.6'>
    <pod title='Input interpretation'
        scanner='Identity'
        id='Input'
        position='100'
        error='false'
        numsubpods='1'>
      <subpod title=''>
      <plaintext>monoid</plaintext>
      </subpod>
      <expressiontypes>
      <expressiontype name='Default' />
      </expressiontypes>
    </pod>
    <pod title='Definition'
        scanner='Data'
        id='DefinitionPod:MathWorldData'
        position='300'
        error='false'
        numsubpods='1'
        primary='true'>
      <subpod title=''>
      <plaintext>A monoid is a set that is closed under an associative binary operation and has an identity element I element S such that for all a element S, Ia = aI = a. Note that unlike a group, its elements need not have inverses. It can also be thought of as a semigroup with an identity element.
    A monoid must contain at least one element.
    A monoid that is commutative is, not surprisingly, known as a commutative monoid.</plaintext>
      </subpod>
      <expressiontypes>
      <expressiontype name='Default' />
      </expressiontypes>
      <infos count='1'>
      <info>
        <link url='http://mathworld.wolfram.com/Monoid.html'
            text='More information' />
      </info>
      </infos>
    </pod>
    <pod title='Related topics'
        scanner='Data'
        id='RelatedTopicsPod:MathWorldData'
        position='400'
        error='false'
        numsubpods='1'>
      <subpod title=''>
      <plaintext>binary operator | commutative monoid | free idempotent monoid | group | semigroup | submonoid</plaintext>
      </subpod>
      <expressiontypes>
      <expressiontype name='Default' />
      </expressiontypes>
    </pod>
    <pod title='Subject classifications'
        scanner='Data'
        id='SubjectPod:MathWorldData'
        position='500'
        error='false'
        numsubpods='1'>
      <subpod title='MathWorld'>
      <plaintext>group-like objects</plaintext>
      </subpod>
      <expressiontypes>
      <expressiontype name='Default' />
      </expressiontypes>
      <states count='1'>
      <state name='Show details'
          input='SubjectPod:MathWorldData__Show details' />
      </states>
    </pod>
    </queryresult>
    """
  end
end
