/*
 * FIR.cpp
 * Created by SystemVue C++ Code Generator
 * Copyright © 2000-2014, Keysight Technologies, Inc.
 */

#include "FIR.h"

#ifndef SV_CODE_GEN
DEFINE_MODEL_INTERFACE(FIR)
{
	bool bStatus = true;
	bStatus = SystemVueModelBuilder::FIR< double >::DefineInterface(model);
	model.SetModelName("FIR");
	model.SetModelCodeGenName("FIR");
	model.SetModelNamespace("");
	model.AddModelHeaderFile("FIR.h");
	model.AddModelSourceFile("FIR.cpp");
	model.EnablePartAndModelGeneration();
	return bStatus;
}
#endif

