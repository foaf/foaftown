/* 	
 * 
 *    Copyright 2004 Ian Sollars
 * 
 *    Licensed under the Apache License, Version 2.0 (the "License");
 *    you may not use this file except in compliance with the License.
 *    You may obtain a copy of the License at
 * 
 *        http://www.apache.org/licenses/LICENSE-2.0
 * 
 *    Unless required by applicable law or agreed to in writing, software
 *    distributed under the License is distributed on an "AS IS" BASIS,
 *    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *    See the License for the specific language governing permissions and
 *    limitations under the License.
 * 
 * Created on Jun 20, 2004, 2:08:03 PM by Ian
 *
 */
//package net.ex_337._dev;
//do we need this? 

package com.xmlns.foaftown.xml;


/**
 * 
 * Contains (mostly) final flags to control debugging and logging.
 * 
 * @author Ian
 */
public final class DevelopmentMode {

	/**
	 * Controls logging in the GradientSVGCanvas 
	 */
    public static final boolean GradientSVGCanvas_DEBUG = false;
    
	/**
	 * Controls logging in PacketRouter
	 */
    
	public static final boolean PacketRouter_DEBUG = false;
	
	/**
	 * If true, dumps all packets to this classes Logger
	 */
	public static final boolean PacketRouter_TRACE = false;
	
	/**
	 * Controls logging in XMLUtils
	 */
	public static final boolean XMLUtils_DEBUG = false;
	
	/**
	 * If true, all Loggers echo all logged strings to System.out
	 */
	public static boolean Logger_ECHO_OUT = false;
	
	/**
	 * Controls logging in DOM2XMLPullBuilder
	 */
	public static final boolean DOM2XMLPullBuilder_DEBUG = false;
	
	/**
	 * Controls loggin in GradientRhinoInterpreter
	 */
	public static final boolean GradientRhinoInterpreter_DEBUG = false;

	/**
	 * Controls logging in TargetPathPacketExtensionProvider
	 */
	public static final boolean TargetPathPacketExtensionProvider_DEBUG = false;

	/**
	 * Controls logging in DirectivePacketExtension
	 */
	public static final boolean DirectivePacketExtension_DEBUG = false;

	/**
	 * Controls logging in DirectivePacketExtensionProvider
	 */
	public static final boolean DirectivePacketExtensionProvider_DEBUG = false;

	/**
	 * Controls logging in BaseGradientService
	 */
	public static final boolean BaseGradientService_DEBUG = false;

	/**
	 * Controls logging in TestRPCService
	 */
	public static final boolean TestRPCService_DEBUG = false;

	/**
	 * Controls logging in DemoGradientSession
	 */
	public static final boolean DemoSession_DEBUG = false;

}
