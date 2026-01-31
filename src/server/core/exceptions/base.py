"""
Core exception definitions following ERROR_HANDLING_STANDARD.md
Error codes format: [MODULE]_[SEVERITY]_[TYPE]
Ejemplos: SYS_001 (System Connection Error), DB_002 (Database Write Error)
"""


class BaseAppError(Exception):
    """Base exception for all application-specific errors"""

    def __init__(self, code: str, message: str, details: dict = None):
        self.code = code
        self.message = message
        self.details = details or {}
        super().__init__(f"[{code}] {message}")

    def to_dict(self) -> dict:
        """Convert exception to API-friendly JSON response"""
        return {
            "error_code": self.code,
            "error_message": self.message,
            "details": self.details,
        }


class VectorStoreError(BaseAppError):
    """Errores en la capa de persistencia vectorial (ChromaDB)"""

    pass
