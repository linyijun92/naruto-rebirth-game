import { Request, Response, NextFunction } from 'express';
import { verifyToken } from '../config/jwt';
import { createError } from './error';

export interface AuthRequest extends Request {
  userId?: string;
  username?: string;
}

export const authenticate = (
  req: AuthRequest,
  res: Response,
  next: NextFunction,
): void => {
  try {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
      throw createError('No token provided', 401);
    }

    const token = authHeader.substring(7);
    const decoded = verifyToken(token);

    req.userId = decoded.userId;
    req.username = decoded.username;

    next();
  } catch (error) {
    next(createError('Invalid or expired token', 401));
  }
};

// 可选认证（不强制要求token）
export const optionalAuth = (
  req: AuthRequest,
  res: Response,
  next: NextFunction,
): void => {
  try {
    const authHeader = req.headers.authorization;

    if (authHeader && authHeader.startsWith('Bearer ')) {
      const token = authHeader.substring(7);
      const decoded = verifyToken(token);
      req.userId = decoded.userId;
      req.username = decoded.username;
    }

    next();
  } catch (error) {
    // 可选认证失败时不抛出错误
    next();
  }
};
