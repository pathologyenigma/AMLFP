import std.stdio;
import std.traits;
import std.string;
import std.math;

template isVector(T)
{
	const isVector = __traits(compiles, (T t) { return is(T == Vector!()); });
}

class Vector(int len = 0, T = float) if (isFloatingPoint!(T) || isVector!(T))
{
	enum ErrorType
	{
		/// when there is a not supported computation happened
		/// this type is a template so not every type supported all functions inside the template
		/// be sure you calling the right function, or you will get this error
		NotSupportedComputation,
		/// this only happens when something for a type is not implemented yet,
		/// it is not your fault, but also will panic the pragram,
		/// sponsor me for solving this more quickly.
		NotImplementedComputation
	}
	/// errors happens in this type
	/// even not an Error type,
	/// only will represent the error print at compile time
	class VectorError(ErrorType type, string pos, string opName, string pos_ = null)
	{

		ErrorType error_type;
		this()() if (type == ErrorType.NotSupportedComputation)
		{
			pragma(msg, "WARNING: ", pos, " not supported", opName, " operation");
		}

		this()() if (type == ErrorType.NotImplementedComputation)
		{
			pragma(msg, "WARNING: ",
				pos,
				" ",
				opName,
				" ",
				pos_,
				" operation not implemented yet, so you will always get 0 from this");
		}
	}

	this(T t)
	{
		this.data[] = t;
	}

	this()(double fill) if (isFloatingPoint!(T))
	{
		this.data[] = fill;
	}

	this()(double fill) if (isVector!(T))
	{
		auto v = new T(fill);
		this.data[] = v;
	}

	this()
	{
		static if (isVector!(T))
		{
			this.data[] = new T();
		}
		else
		{
			this.data[] = 0;
		}
	}

	auto opUnary(string op)() if (op == "-")
	{
		foreach (ref item; this.data)
		{
			item = -item;
		}
		return this;
	}

	auto opUnary(string op)() if (op == "--")
	{
		foreach (ref item; this.data)
		{
			--item;
		}
		return this;
	}

	auto opUnary(string op)() if (op == "++")
	{
		foreach (ref item; this.data)
		{
			++item;
		}
		return this;
	}

	auto opIndex(int index) nothrow
	{
		return this.data[index];
	}

	void opIndexAssign(T t, int t1) nothrow
	{
		this.data[t1] = t;
	}

	auto opBinary(string op)(Vector v) if (op == "+")
	{
		auto res = new Vector();
		auto i = 0;
		while (i < len)
		{
			res[i] = this.data[i] + v[i];
			i++;
		}
		return res;
	}

	auto opBinary(string op)(Vector v) if (op == "-")
	{
		auto res = new Vector();
		auto i = 0;
		while (i < len)
		{
			res[i] = this.data[i] - v[i];
			i++;
		}
		return res;
	}

	auto opBinary(string op)(Vector v) if (op == "*")
	{
		auto res = new Vector();
		auto i = 0;
		while (i < len)
		{
			res[i] = this.data[i] * v[i];
			i++;
		}
		return res;
	}

	auto opBinary(string op)(T t) if (op == "*" && isFloatingPoint!(T))
	{
		auto res = new Vector();
		auto i = 0;
		while (i < len)
		{
			res[i] = this.data[i] * t;
			i++;
		}
		return res;
	}

	auto opBinary(string op)(T t) if (op == "*" && isVector!(T))
	{
		new this.VectorError!(this.ErrorType.NotImplementedComputation, typeof(this).stringof, "*", T.stringof);
		return 0;
	}

	void opBinary(string op)(Vector v) if (op == "+=")
	{
		auto i = 0;
		while (i < len)
		{
			this.data[i] += v[i];
			i++;
		}
	}

	override string toString() const nothrow
	{
		string s = "[";
		int i = 0;
		while (i < len - 1)
		{
			s = format("%s%s,", s, this.data[i]);
			++i;
		}
		s = format("%s%s]", s, this.data[i]);
		return s;
	}

	int opApply(scope int delegate(size_t index, ref T) dg)
	{
		int result = 0;

		foreach (index, item; this.data)
		{
			result = dg(index, item);
			if (result)
				break;
		}

		return result;
	}

	int opApply(scope int delegate(ref T) dg)
	{
		int result = 0;

		foreach (item; this.data)
		{
			result = dg(item);
			if (result)
				break;
		}

		return result;
	}

	auto length_squared()() if (isFloatingPoint!(T))
	{
		auto res = 0.0;
		foreach (item; this.data)
		{
			res += item * item;
		}
		return res;
	}

	void length_squared()() if (isVector!(T))
	{
		new this.VectorError!(this.ErrorType.NotSupportedComputation, typeof(this).stringof, "length_squared");
	}

	auto length()() if (isFloatingPoint!(T))
	{
		return sqrt(this.length_squared());
	}

	void length()() if (isVector!(T))
	{
		new this.VectorError!(this.ErrorType.NotSupportedComputation, typeof(this).stringof, "length");
	}

	T[len] data;
}
