from twisted.enterprise import adbapi
from twisted.python import log
from MySQLdb import OperationalError

class ReconnectingConnectionPool(adbapi.ConnectionPool):
    def _runInteraction(self, interaction, *args, **kw):
        try:
            return adbapi.ConnectionPool._runInteraction(self, interaction, *args, **kw)
        except OperationalError, e:
            error_messages = ("mysql server has gone away", "lost connection to mysql server during query")
            if any([x in str(e).lower() for x in error_messages]):
                log.msg(" >> Resetting DB pool")
                for conn in self.connections.values():
                    self._close(conn)
                self.connections.clear()
                return adbapi.ConnectionPool._runInteraction(self, interaction, *args, **kw)
            else:
                raise