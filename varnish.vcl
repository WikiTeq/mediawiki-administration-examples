#
# This is an example VCL file for Varnish.
#
# It does not do anything by default, delegating control to the
# builtin VCL. The builtin VCL is called when there is no explicit
# return statement.
#
# See the VCL chapters in the Users Guide for a comprehensive documentation
# at https://www.varnish-cache.org/docs/.

# Marker to tell the VCL compiler that this VCL has been written with the
# 4.0 or 4.1 syntax.
vcl 4.1;

# Default backend definition. Set this to point to your content server.
backend default {
    .host = "127.0.0.1";
    .port = "8080";
}

# access control list for "purge": open to only localhost and other local nodes
acl purge {
    "127.0.0.1";
}

sub vcl_recv {
    # Happens before we check if we have this in cache already.
    #
    # Typically you clean up the request here, removing cookies you don't need,
    # rewriting the request, etc.
    set req.http.X-Forwarded-For = req.http.X-Forwarded-For + ", " + client.ip;

    set req.backend_hint= default;

    # This uses the ACL action called "purge". Basically if a request to
    # PURGE the cache comes from anywhere other than localhost, ignore it.
    if (req.method == "PURGE") {
        if (!client.ip ~ purge) {
            return (synth(405, "Not allowed."));
        } else {
            return (purge);
        }
    }

    # Pass requests from logged-in users directly.
    # Only detect cookies with "session" and "Token" in file name, otherwise nothing get cached.
    if (req.http.Authorization || req.http.Cookie ~ "([sS]ession|Token)=") {
        return (pass);
    } /* Not cacheable by default */

    # normalize Accept-Encoding to reduce vary
    if (req.http.Accept-Encoding) {
      if (req.http.User-Agent ~ "MSIE 6") {
        unset req.http.Accept-Encoding;
      } elsif (req.http.Accept-Encoding ~ "gzip") {
        set req.http.Accept-Encoding = "gzip";
      } elsif (req.http.Accept-Encoding ~ "deflate") {
        set req.http.Accept-Encoding = "deflate";
      } else {
        unset req.http.Accept-Encoding;
      }
    }

    return (hash);
}

sub vcl_pipe {
    # Note that only the first request to the backend will have
    # X-Forwarded-For set.  If you use X-Forwarded-For and want to
    # have it set for all requests, make sure to have:
    # set req.http.connection = "close";

    # This is otherwise not necessary if you do not do any request rewriting.

    set req.http.connection = "close";
}

# Called if the cache has a copy of the page.
sub vcl_hit {
    if (!obj.ttl > 0s) {
        return (pass);
    }
}

sub vcl_backend_response {
    # Happens after we have read the response headers from the backend.
    #
    # Here you clean the response headers, removing silly Set-Cookie headers
    # and other mistakes your backend does.
    if (beresp.status == 500 || beresp.status == 502 || beresp.status == 503 || beresp.status == 504) {
      set beresp.uncacheable = true;
      return (deliver);
    }

    if (!beresp.ttl > 0s) {
      set beresp.uncacheable = true;
      return (deliver);
    }

    if (beresp.http.Set-Cookie) {
      set beresp.uncacheable = true;
      return (deliver);
    }

    if (beresp.http.Authorization && !beresp.http.Cache-Control ~ "public") {
      set beresp.uncacheable = true;
      return (deliver);
    }

    return (deliver);
}

sub vcl_deliver {
    # Happens when we have all the pieces we need, and are about to send the
    # response to the client.
    #
    # You can do accounting or modifying the final object here.
}
