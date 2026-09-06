import 'package:flutter/material.dart';
import 'interaction/bloom.dart';
import 'interaction/syvax.dart';

class BloomPage extends StatelessWidget {
  final ValueChanged<BloomSuboption> onSub;
  final ValueChanged<String> onSyvax;
  final bool busy;
  const BloomPage({super.key,required this.onSub,required this.onSyvax,required this.busy});
  @override
  Widget build(BuildContext context)=>SingleChildScrollView(
    padding:const EdgeInsets.all(24),
    child:Row(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Expanded(child:Container(height:590,decoration:BoxDecoration(color:const Color(0x4010142A),borderRadius:BorderRadius.circular(22),border:Border.all(color:const Color(0x242E3354))),child:Bloom(onSelected:(_){},onSuboption:onSub))),
      const SizedBox(width:18),SizedBox(width:360,child:Syvax(onSubmit:onSyvax,busy:busy)),
    ]),
  );
}
