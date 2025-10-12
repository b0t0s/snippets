using Newtonsoft.Json;
using PostSharp.Aspects;
using PostSharp.Serialization;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Reflection;

namespace Extensions.Logging;

/// <summary>
/// Applicable for all classes without constructor
/// </summary>
[PSerializable]
public class PropertyLoggingAspect : OnMethodBoundaryAspect
{
    private static readonly string LogPrefix = "[PropertyLog]";
    private static readonly string Separator = new('-', 50);

    public override void OnEntry(MethodExecutionArgs args)
    {
        if (IsConstructor(args.Method) || ShouldSkipLogging(args.Method)) return;

        var callerName = GetCallerMethodName();
        var logDescription = $"{LogPrefix} {callerName} - {GetMemberType(args.Method)} {args.Method.Name} - Starting.";

        if (args.Arguments != null && args.Arguments.Count > 0)
        {
            var parameters = args.Method.GetParameters().ToDictionary(key => key.Name, value => args.Arguments[value.Position]);
            logDescription += $" Parameters: {JsonConvert.SerializeObject(parameters)}";
        }

        Debug.WriteLine($"{Separator}\n{logDescription}\n{Separator}");
        args.MethodExecutionTag = Stopwatch.StartNew();
    }

    public override void OnSuccess(MethodExecutionArgs args)
    {
        if (IsConstructor(args.Method) || ShouldSkipLogging(args.Method)) return;

        var callerName = GetCallerMethodName();
        Debug.WriteLine($"{LogPrefix} {callerName} - {GetMemberType(args.Method)} {args.Method.Name} - Succeeded.");
    }

    public override void OnExit(MethodExecutionArgs args)
    {
        if (IsConstructor(args.Method) || ShouldSkipLogging(args.Method)) return;

        var callerName = GetCallerMethodName();
        var sw = (Stopwatch)args.MethodExecutionTag;
        sw.Stop();

        Debug.WriteLine($"{LogPrefix} {callerName} - {GetMemberType(args.Method)} {args.Method.Name} - Exited (total execution time in MS: {sw.ElapsedMilliseconds}).");
    }

    public override void OnException(MethodExecutionArgs args)
    {
        if (IsConstructor(args.Method) || ShouldSkipLogging(args.Method)) return;

        var callerName = GetCallerMethodName();
        var logDescription = $"{LogPrefix} {callerName} - {GetMemberType(args.Method)} {args.Method.Name} - Failed.";

        if (args.Exception != null)
        {
            logDescription += $" Message: {args.Exception.Message}";
        }

        Debug.WriteLine($"{Separator}\n{logDescription}\n{Separator}");
    }

    private string GetCallerMethodName()
    {
        var stackTrace = new StackTrace();
        var callerMethod = stackTrace.GetFrames()?.FirstOrDefault(frame =>
            frame.GetMethod().DeclaringType != typeof(PropertyLoggingAspect)
        )?.GetMethod();

        return $"{callerMethod?.DeclaringType?.FullName}.{callerMethod?.Name}";
    }

    private static bool IsConstructor(MethodBase method)
    {
        return method.IsConstructor;
    }

    private bool ShouldSkipLogging(MethodBase method)
    {
        return method.IsDefined(typeof(NoLoggingAttribute), inherit: true);
    }

    private string GetMemberType(MethodBase method)
    {
        if (method.IsConstructor)
            return "Constructor";
        if (method.IsSpecialName) // Property getter or setter
            return method.Name.StartsWith("get_") ? "Property Getter" : "Property Setter";
        return "Method";
    }
}
